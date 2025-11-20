using Mapster;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Commom.PasswordService;
using NovinskiPortal.Model.Requests.Authentication;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Enumerations;
using NovinskiPortal.Services.Services.EmailService;
using NovinskiPortal.Services.Services.JwtService;

namespace NovinskiPortal.Services.Services.AuthService
{
    public class AuthService : IAuthService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IPasswordService _passwordService;
        private readonly IJwtService _jwtService;
        private readonly IEmailService _emailService;

        public AuthService(NovinskiPortalDbContext context, IPasswordService passwordService, IJwtService jwtService, IEmailService emailService)
        {
            _context = context;
            _passwordService = passwordService;
            _jwtService = jwtService;
            _emailService = emailService;
        }
        public async Task<AuthResponse?> LoginAsync(LoginRequest loginRequest)
        {
            var input = loginRequest.EmailOrUsername.Trim().ToLowerInvariant();
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync
                    (u => u.Username.ToLower() == input || 
                    u.Email.ToLower() == input);

            if (user is null)  return null;

            if (!user.Active)  return null;

            var isValid = _passwordService.VerifyPassword(loginRequest.Password, user.PasswordSalt, user.PasswordHash);
            if (!isValid) return null;

            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var token = _jwtService.GenerateToken(user);

            //await _usersService.SetLastLoginAt(user.Id, DateTime.UtcNow);

            var authResponse = new AuthResponse
            {
                Token = token,
                User = user.Adapt<UserResponse>()
            };

            return authResponse;

        }

        public async Task<AuthResponse?> RegisterAsync(RegisterRequest registerRequest)
        {
            var username = registerRequest.Username.Trim();
            var email = registerRequest.Email.Trim();

            // Ako želiš zabraniti registraciju istog username/email čak i kad je korisnik soft-deleted,
            // ova provjera je dovoljna. (Ako želiš dozvoliti – onda dodaj u where: && !u.IsDeleted)
            var existUser = await _context.Users
                .AnyAsync(u => u.Username.ToLower() == username.ToLower() ||
                    u.Email.ToLower() == email.ToLower());

            if (existUser) return null;

            var defaultRoleId = await _context.Roles
                .Where(r => r.Name == nameof(Roles.User))
                .Select(r => r.Id)
                .SingleAsync();

            var salt = _passwordService.GenerateSalt();
            var hash = _passwordService.HashPassword(registerRequest.Password, salt);

            var newUser = new User
            {
                FirstName = registerRequest.FirstName,
                LastName = registerRequest.LastName,
                Nick = registerRequest.Nick ?? string.Empty,
                Username = username,
                Email = email,
                PasswordSalt = salt,
                PasswordHash = hash,
                RoleId = defaultRoleId,
                CreatedAt = DateTime.UtcNow,
                Active = true,
                IsDeleted = false
            };

            _context.Add(newUser);
            await _context.SaveChangesAsync(); 
            await _context.Entry(newUser).Reference(u => u.Role).LoadAsync();

            var token = _jwtService.GenerateToken(newUser);

            var authResponse = new AuthResponse
            {
                Token = token,
                User = newUser.Adapt<UserResponse>()
            };

            return authResponse;
        }

        public async Task<bool> IsUsernameTakenAsync(string username)
        {
            if (string.IsNullOrWhiteSpace(username))
                return false;

            return await _context.Users.AnyAsync(u => u.Username.Trim() == username.Trim().ToLower());
        }

        public async Task<bool> IsEmailTakenAsync(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            return await _context.Users.AnyAsync(u => u.Email.Trim() == email.Trim().ToLower());
        }

        public async Task ForgotPasswordAsync(ForgotPasswordRequest forgotPasswordRequest)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == forgotPasswordRequest.Email && !u.IsDeleted && u.Active);

            if (user == null)
            {
                await Task.Delay(500);
                return;
            }

            var oldTokens = _context.PasswordResetTokens
                .Where(t => t.UserId == user.Id && !t.Used && t.ExpiresAt > DateTime.UtcNow);

            _context.PasswordResetTokens.RemoveRange(oldTokens);

            var tokenValue = Guid.NewGuid().ToString("N");

            var token = new PasswordResetToken
            {
                UserId = user.Id,
                Token = tokenValue,
                ExpiresAt = DateTime.UtcNow.AddHours(1)
            };

            _context.PasswordResetTokens.Add(token);
            await _context.SaveChangesAsync();

            var resetLink = $"https://localhost:7060/reset-password?token={tokenValue}";

            var subject = "Reset lozinke - Novinski portal";
            var body = $@"
                       Pozdrav {user.FirstName},<br/><br/>
                       Zaprimili smo zahtjev za reset lozinke.<br/>
                       Da promijenite lozinku, kliknite na link:<br/><br/>
                       <a href=""{resetLink}"">{resetLink}</a><br/><br/>
                       Ako niste Vi tražili reset, ignorišite ovaj email.
                       ";

            await _emailService.SendAsync(user.Email, subject, body);
        }

        public async Task<bool> ResetPasswordAsync(ResetPasswordRequest resetPasswordRequest)
        {
            var token = await _context.PasswordResetTokens
                .Include(t => t.User)
                .FirstOrDefaultAsync(t => t.Token == resetPasswordRequest.Token);

            if (token == null)
                return false;

            if (token.Used)
                return false;

            if (token.ExpiresAt < DateTime.UtcNow)
                return false;

            var user = token.User;

            if (user == null || user.IsDeleted)
                return false;

            if (!user.Active)
                return false;

            var salt = _passwordService.GenerateSalt();
            var hash = _passwordService.HashPassword(resetPasswordRequest.NewPassword, salt);

            user.PasswordSalt = salt;
            user.PasswordHash = hash;

            token.Used = true;
            token.UsedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return true;
        }
    }
}

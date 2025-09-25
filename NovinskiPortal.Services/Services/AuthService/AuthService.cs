using Mapster;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Commom.PasswordService;
using NovinskiPortal.Model.Requests.Authentication;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Enumerations;
using NovinskiPortal.Services.Services.JwtService;

namespace NovinskiPortal.Services.Services.AuthService
{
    public class AuthService : IAuthService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IPasswordService _passwordService;
        private readonly IJwtService _jwtService;

        public AuthService(NovinskiPortalDbContext context, IPasswordService passwordService, IJwtService jwtService)
        {
            _context = context;
            _passwordService = passwordService;
            _jwtService = jwtService;
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
    }
}

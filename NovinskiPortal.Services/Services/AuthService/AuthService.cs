

using Mapster;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.Authentication;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.JwtService;
using NovinskiPortal.Services.Services.PasswordService;

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
                .AsNoTracking()
                .FirstOrDefaultAsync
                    (u => u.Username.ToLower() == input || 
                    u.Email.ToLower() == input);

            if (user is null)  return null;

            if (!user.Active)  return null;

            var isValid = _passwordService.VerifyPassword(loginRequest.Password, user.PasswordSalt, user.PasswordHash);
            if (!isValid) return null;

            var token = _jwtService.GenerateToken(user);

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

            var existUser = await _context.Users
                .AnyAsync(u => u.Username.ToLower() == username.ToLower() ||
                    u.Email.ToLower() == email.ToLower());

            if (existUser) return null;

            var salt = _passwordService.GenerateSalt();
            var hash = _passwordService.HashPassword(registerRequest.Password, salt);

            var newUser = new User
            {
                FirstName = registerRequest.FirstName,
                LastName = registerRequest.LastName,
                Nick = registerRequest.Nick ?? string.Empty,
                Username = registerRequest.Username,
                Email = registerRequest.Email,
                PasswordSalt = salt,
                PasswordHash = hash,
                Role = 2,
                Active = true
            };

            _context.Add(newUser);
            await _context.SaveChangesAsync();

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

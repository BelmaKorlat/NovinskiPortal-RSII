

using Mapster;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Services.PasswordService;

namespace NovinskiPortal.Services.Services.UserService
{
    public class UserService : IUserService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IPasswordService _passwordService;

        public UserService(NovinskiPortalDbContext context, IPasswordService passwordService)
        {
            _context = context;
            _passwordService = passwordService;
        }

        public async Task<ProfileResponse?> GetMeAsync(int userId)
        {
            var user = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId);
            return user.Adapt<ProfileResponse>();
        }
        public async Task<ProfileResponse?> UpdateMeAsync(int userId, UpdateProfileRequest updateProfileRequest)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user is null) return null;

            user.FirstName = updateProfileRequest.FirstName;
            user.LastName = updateProfileRequest.LastName;
            user.Username = updateProfileRequest.Username;

            await _context.SaveChangesAsync();
            return user.Adapt<ProfileResponse>();
        }
        public async Task<bool> ChangeMyPasswordAsync(int userId, ChangePasswordRequest changePasswordRequest)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user is null) return false;

            var isCurrentPasswordValid = _passwordService.VerifyPassword(changePasswordRequest.CurrentPassword, user.PasswordSalt, user.PasswordHash);
            if (!isCurrentPasswordValid) return false;

            if (changePasswordRequest.NewPassword == changePasswordRequest.CurrentPassword) return false;

            var salt = _passwordService.GenerateSalt();
            user.PasswordSalt = salt;
            user.PasswordHash = _passwordService.HashPassword(changePasswordRequest.NewPassword, salt);

            if (changePasswordRequest.NewPassword != changePasswordRequest.ConfirmNewPassword) return false;

            await _context.SaveChangesAsync();
            return true;
        }


    }
}

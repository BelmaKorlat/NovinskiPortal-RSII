

using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.UserService
{
    public interface IUserService
    {
        Task<ProfileResponse?> GetByIdAsync(int userId);
        Task<ProfileResponse?> UpdateAsync(int userId, UpdateProfileRequest updateProfileRequest);
        Task<bool> ChangePasswordAsync(int userId, ChangePasswordRequest changePasswordRequest);
    }
}

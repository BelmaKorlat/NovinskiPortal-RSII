

using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.UserService
{
    public interface IUserService
    {
        Task<ProfileResponse?> GetMeAsync(int userId);
        Task<ProfileResponse?> UpdateMeAsync(int userId, UpdateProfileRequest updateProfileRequest);
        Task<bool> ChangeMyPasswordAsync(int userId, ChangePasswordRequest changePasswordRequest);
    }
}



using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.AdminService
{
    public interface IAdminUserService : ICRUDService<UserAdminResponse, UserSearchObject, CreateUserRequest, UpdateUserRequest>
    {
        Task<UserAdminResponse?> ToggleStatusUserAsync(int id);
        Task<UserAdminResponse?> ChangeRoleAsync(int id, int role);
        Task<bool> SoftDeleteAsync(int id);
        Task<bool> AdminChangePasswordAsync(int id, AdminChangePasswordRequest adminChangePasswordRequest);
        Task<bool> UnbanUserCommentsAsync(int id);

    }
}

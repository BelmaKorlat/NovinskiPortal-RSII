

using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.IServices;

namespace NovinskiPortal.Services.Services.AdminService
{
    public interface IAdminUserService : ICRUDService<UserAdminResponse, UserSearchObject, CreateUserRequest, UpdateUserRequest>
    {
        Task<bool> SetActiveAsync(int id, bool active);
        Task<bool> ChangeRoleAsync(int id, int role);
    }
}

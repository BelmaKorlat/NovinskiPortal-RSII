using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.Category;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.AdminService;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/Admin/Users")]
    [ApiController]
    [Authorize(Roles = "Admin")] 
    public class AdminUsersController : BaseCRUDController<UserAdminResponse, UserSearchObject, CreateUserRequest, UpdateUserRequest>
    {
        private readonly IAdminUserService _adminService;

        public AdminUsersController(IAdminUserService service) : base(service)
        {
            _adminService = service;
        }

        [HttpDelete("{id}/soft-delete")]
        public async Task<IActionResult> SoftDelete(int id)
        {
            var ok = await _adminService.SoftDeleteAsync(id);
            return ok ? NoContent() : NotFound();
        }

        [HttpPost("{id}/restore")]
        public async Task<IActionResult> Restore(int id)
        {
            var ok = await _adminService.RestoreAsync(id);
            return ok ? NoContent() : NotFound();
        }


        [HttpPatch("{id}/role")]
        public async Task<IActionResult> ChangeRole(int id, [FromBody] int role)
        {
            var userDto = await _adminService.ChangeRoleAsync(id, role);
            return userDto is null ? NotFound() : Ok(userDto);
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> ToggleStatusUserAsync(int id)
        {
            var userDto = await _adminService.ToggleStatusUserAsync(id);
            return userDto is null ? NotFound() : Ok(userDto);
       
        }
    }
}

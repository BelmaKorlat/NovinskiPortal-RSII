using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.Category;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.AdminService;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/admin/users")]
    [ApiController]
    [Authorize(Roles = "1")] // admin
    public class AdminUsersController : BaseCRUDController<UserAdminResponse, UserSearchObject, CreateUserRequest, UpdateUserRequest>
    {
        private readonly IAdminUserService _adminService;

        public AdminUsersController(IAdminUserService service) : base(service)
        {
            _adminService = service;
        }

        [HttpPatch("{id}/role")]
        public async Task<IActionResult> ChangeRole(int id, [FromBody] int role)
        {
            var result = await _adminService.ChangeRoleAsync(id, role);
            if (!result) return NotFound();
            return NoContent();
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> SetActive(int id, [FromBody] bool active)
        {
            var result = await _adminService.SetActiveAsync(id, active);
            if (!result) return NotFound();
            return NoContent();
        }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Services.Services.UserService;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [ApiController]
    [Route("api/Users")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        private int GetUserId()
        {
            var id = User.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            return int.Parse(id!);
        }

        [HttpGet()]
        public async Task<IActionResult> GetByIdAsync()
        {
            var me = await _userService.GetByIdAsync(GetUserId());

            if (me is null) return NotFound();
            return Ok(me);
        }

        [HttpPut()]
        public async Task<IActionResult> UpdateAsync([FromBody] UpdateProfileRequest updateProfileRequest)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _userService.UpdateAsync(GetUserId(), updateProfileRequest);

            if (updated is null)
                return NotFound();

            return Ok(updated);
        }

        [HttpPut("password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest changePasswordRequest)
        {
            /*  var updatedPassword = await _userService.ChangePasswordAsync(GetUserId(), changePasswordRequest);
              if (changePasswordRequest.NewPassword != changePasswordRequest.ConfirmNewPassword) return BadRequest();
              if (!updatedPassword) return BadRequest();
              return NoContent();*/
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updatedPassword = await _userService.ChangePasswordAsync(GetUserId(), changePasswordRequest);

            if (!updatedPassword)
                return BadRequest();

            return NoContent();
        }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Services.Services.UserService;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [ApiController]
    [Route("api/users")]
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

        [HttpGet("me")]
        public async Task<IActionResult> Me()
        {
            var me = await _userService.GetMeAsync(GetUserId());

            if (me is null) return NotFound();
            return Ok(me);
        }

        [HttpPut("me")]
        public async Task<IActionResult> UpdateMe([FromBody] UpdateProfileRequest updateProfileRequest)
        {
            var updated = await _userService.UpdateMeAsync(GetUserId(), updateProfileRequest);

            if (updated is null)
                return NotFound();

            return Ok(updated);
        }

        [HttpPut("me/password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest changePasswordRequest)
        {
            var updatedPassword = await _userService.ChangeMyPasswordAsync(GetUserId(), changePasswordRequest);
            if (changePasswordRequest.NewPassword != changePasswordRequest.ConfirmNewPassword) return BadRequest();
            if (!updatedPassword) return BadRequest();
            return NoContent();
        }
    }
}

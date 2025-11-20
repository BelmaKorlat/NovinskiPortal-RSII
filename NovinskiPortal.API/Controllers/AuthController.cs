
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.Authentication;
using NovinskiPortal.Services.Services.AuthService;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> LoginAsync([FromBody] LoginRequest loginRequest)
        {
            var result = await _authService.LoginAsync(loginRequest);
            if (result is null)
                return Unauthorized();

            return Ok(result); 
        }

        [HttpPost("register")]
        public async Task<IActionResult> RegisterAsync([FromBody] RegisterRequest registerRequest)
        {
            var result = await _authService.RegisterAsync(registerRequest);
            if (result is null)
                return Conflict();

            return Ok(result);
        }

        [HttpGet("check-username")]
        public async Task<IActionResult> CheckUsernameAsync([FromQuery] string username)
        {
            var taken = await _authService.IsUsernameTakenAsync(username);
            return Ok(new { taken });
        }

        [HttpGet("check-email")]
        public async Task<IActionResult> CheckEmailAsync([FromQuery] string email)
        {
            var taken = await _authService.IsEmailTakenAsync(email);
            return Ok(new { taken });
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest forgotPasswordRequest)
        {
            if (string.IsNullOrWhiteSpace(forgotPasswordRequest.Email))
                return BadRequest();

            await _authService.ForgotPasswordAsync(forgotPasswordRequest);
            return Ok();
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (!ModelState.IsValid)
            {
                return ValidationProblem(ModelState);
            }

            var success = await _authService.ResetPasswordAsync(request);

            if (!success)
            {
                return BadRequest();
            }

            return Ok();
        }

    }
}



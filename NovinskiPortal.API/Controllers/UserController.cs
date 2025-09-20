using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Constants;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.PasswordService;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IPasswordService _passwordService;

        public UserController(NovinskiPortalDbContext contex, IPasswordService passwordService)
        {
            _context = contex;
            _passwordService = passwordService;
        }


        [HttpPost]
        public async Task<User> CreateUserRequestAsync([FromBody] CreateUserRequest createUserRequestDto)
        {
            var salt = _passwordService.GenerateSalt();
            var hash = _passwordService.HashPassword(createUserRequestDto.Password, salt);

            var newUser = new User
            {
                FirstName = createUserRequestDto.FirstName,
                LastName = createUserRequestDto.LastName,
                Nick = createUserRequestDto.Nick ?? string.Empty,
                Username = createUserRequestDto.Username,
                Email = createUserRequestDto.Email,
                PasswordSalt = salt,
                PasswordHash = hash,
                Role = RoleConstants.User, // 2
                Active = true
            };

            await _context.AddAsync(newUser);
            await _context.SaveChangesAsync();

            return newUser;
        }
    }
}

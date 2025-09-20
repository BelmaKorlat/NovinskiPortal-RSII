

using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.Authentication
{
    public class RegisterRequest
    {
        [Required, MaxLength(50)]
        public string FirstName { get; set; } = default!;

        [Required, MaxLength(50)]
        public string LastName { get; set; } = default!;

        [MaxLength(50)]
        public string? Nick { get; set; }

        [Required, MaxLength(100)]
        public string Username { get; set; } = default!;

        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = default!;

        [Required, MinLength(6), MaxLength(100)]
        public string Password { get; set; } = default!;
    }
}

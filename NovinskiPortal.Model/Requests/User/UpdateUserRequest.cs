

using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.User
{
    public class UpdateUserRequest
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
        [Required]
        public int RoleId { get; set; }  // 1/2
        public bool Active { get; set; } = true;
        [MinLength(6)]
        public string? NewPassword { get; set; }
    }
}

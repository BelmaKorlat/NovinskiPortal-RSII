
using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.User
{
    public class UpdateProfileRequest
    {
        [Required, MaxLength(50)]
        public string FirstName { get; set; } = default!;
        [Required, MaxLength(50)]
        public string LastName { get; set; } = default!;
        [Required, MaxLength(100)]
        public string Username { get; set; } = default!;
    }
}

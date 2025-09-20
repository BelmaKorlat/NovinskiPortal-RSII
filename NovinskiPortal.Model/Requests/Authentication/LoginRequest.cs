using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.Authentication
{
    public class LoginRequest
    {
        [Required]
        public string EmailOrUsername { get; set; } = default!;

        [Required]
        public string Password { get; set; } = default!;
    }
}

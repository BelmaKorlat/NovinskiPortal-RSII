

using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.User
{
    public class ChangePasswordRequest
    {
        [Required]
        public string CurrentPassword { get; set; } = default!;
        [Required, MinLength(6)]
        public string NewPassword { get; set; } = default!;
        [Required, MinLength(6)]
        public string ConfirmNewPassword { get; set; } = default!;
    }
}

using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.Authentication
{
    public class ResetPasswordRequest
    {
        /*  [Required]
          public string Token { get; set; } = default!;
          [Required, MinLength(6), MaxLength(100)]
          public string NewPassword { get; set; } = default!;
          [Required, MinLength(6), MaxLength(100)]
          public string ConfirmPassword { get; set; } = default!;*/

        [Required(ErrorMessage = "Token nedostaje ili je neispravan.")]
        public string Token { get; set; } = default!;

        [Required(ErrorMessage = "Lozinka je obavezno polje.")]
        [StringLength(100,
            ErrorMessage = "Lozinka mora imati najmanje 6 znakova.",
            MinimumLength = 6)]
        [DataType(DataType.Password)]
        public string NewPassword { get; set; } = default!;

        [Required(ErrorMessage = "Potvrda lozinke je obavezno polje.")]
        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "Lozinke se ne podudaraju.")]
        public string ConfirmPassword { get; set; } = default!;
    }

}


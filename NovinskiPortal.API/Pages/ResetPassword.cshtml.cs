using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using NovinskiPortal.Model.Requests.Authentication;
using NovinskiPortal.Services.Services.AuthService;
using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.API.Pages
{
    public class ResetPasswordModel : PageModel
    {
        private readonly IAuthService _authService;

        public ResetPasswordModel(IAuthService authService)
        {
            _authService = authService;
        }

        /*[BindProperty]
        public string Token { get; set; } = string.Empty;

        [BindProperty]
        [Required(ErrorMessage = "Lozinka je obavezna")]
        [StringLength(100, ErrorMessage = "Lozinka mora imati najmanje 6 znakova", MinimumLength = 6)]
        [DataType(DataType.Password)]
        public string NewPassword { get; set; } = string.Empty;

        [BindProperty]
        [Required(ErrorMessage = "Potvrda lozinke je obavezna")]
        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "Lozinke se ne podudaraju")]
        public string ConfirmPassword { get; set; } = string.Empty;

        public string? Message { get; set; }

        public void OnGet(string token)
        {
            Token = token;
        }*/


        [BindProperty]
        public ResetPasswordRequest Input { get; set; } = new();

        public string? Message { get; set; }

        public void OnGet(string token)
        {
            Input.Token = token;
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            var success = await _authService.ResetPasswordAsync(Input);

            if (!success)
            {
                ModelState.AddModelError(string.Empty, "Link za reset lozinke je nevažeći ili je istekao.");
                return Page();
            }

            Message = "Lozinka je uspješno promijenjena. Sada se možete prijaviti sa novom lozinkom.";
            return Page();
        }
    }
}



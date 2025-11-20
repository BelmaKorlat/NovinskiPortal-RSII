

using NovinskiPortal.Model.Requests.Authentication;
using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.AuthService
{
    public interface IAuthService
    {
        Task<AuthResponse?> RegisterAsync(RegisterRequest registerRequest);
        Task<AuthResponse?> LoginAsync(LoginRequest loginRequest);

        Task<bool> IsUsernameTakenAsync(string username);
        Task<bool> IsEmailTakenAsync(string email);

        Task ForgotPasswordAsync(ForgotPasswordRequest forgotPasswordRequest);
        Task<bool> ResetPasswordAsync(ResetPasswordRequest resetPasswordRequest);
    }
}

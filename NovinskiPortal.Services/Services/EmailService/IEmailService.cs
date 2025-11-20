
namespace NovinskiPortal.Services.Services.EmailService
{
    public interface IEmailService
    {
        Task SendAsync(string to, string subject, string body);
    }
}

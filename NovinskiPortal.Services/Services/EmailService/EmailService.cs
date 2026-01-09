

using Microsoft.Extensions.Options;
using System.Net.Mail;
using System.Net;

namespace NovinskiPortal.Services.Services.EmailService
{
    public class EmailService: IEmailService
    {
        private readonly SmtpSettings _settings;

        public EmailService(IOptions<SmtpSettings> options)
        {
            _settings = options.Value;
        }

        public async Task SendAsync(string to, string subject, string body)
        {
            var finalBody = body + (_settings.SignatureHtml ?? "");

            using var message = new MailMessage();
            message.From = new MailAddress(_settings.From);
            message.To.Add(to);
            message.Subject = subject;
            message.Body = finalBody;
            message.IsBodyHtml = true; 

            using var client = new SmtpClient(_settings.Host, _settings.Port);
            client.EnableSsl = _settings.EnableSsl;
            client.Credentials = new NetworkCredential(_settings.Username, _settings.Password);

            await client.SendMailAsync(message);
        }
    }
}

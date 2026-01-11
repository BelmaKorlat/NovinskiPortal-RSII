

namespace NovinskiPortal.Services.Services.EmailService
{
   public class SmtpSettings
    {
        public string Host { get; set; } = default!;
        public int Port { get; set; }
        public bool EnableSsl { get; set; }
        public string From { get; set; } = default!;
        public string Username { get; set; } = default!;
        public string Password { get; set; } = default!;
        public string SignatureHtml { get; set; } = "";
   }
}

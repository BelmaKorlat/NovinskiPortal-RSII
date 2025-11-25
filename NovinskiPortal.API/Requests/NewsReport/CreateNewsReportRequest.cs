using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.API.Requests.NewsReport
{
    public class CreateNewsReportRequest
    {
        [EmailAddress]
        public string? Email { get; set; }

        [Required]
        [MinLength(10)]
        public string Text { get; set; } = default!;

        public List<IFormFile>? Files { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.NewsReport
{
    public class CreateNewsReportRequest
    {
        [EmailAddress]
        public string? Email { get; set; }

        [Required]
        [MinLength(10)]
        public string Text { get; set; } = default!;

        public IList<NewsReportFileUpload> Files { get; set; } = new List<NewsReportFileUpload>();
    }
}


namespace NovinskiPortal.Model.Responses
{
    public class ArticleResponse
    {
        public int Id { get; set; }
        public string Headline { get; set; } = default!;
        public string Subheadline { get; set; } = default!;
        public DateTime CreatedAt { get; set; }
        public DateTime PublishedAt { get; set; }
        public bool Active { get; set; }
        public bool HideFullName { get; set; }
        public bool BreakingNews { get; set; }
        public bool Live { get; set; }
        public string Category { get; set; } = default!;
        public string Subcategory { get; set; } = default!;
        public string User { get; set; } = default!;
        public string MainPhotoPath { get; set; } = default!;
        public string Color { get; set; } = default!;
        public int CommentsCount { get; set; }
    }
}

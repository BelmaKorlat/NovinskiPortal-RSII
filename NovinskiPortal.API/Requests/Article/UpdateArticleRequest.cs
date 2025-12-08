namespace NovinskiPortal.API.Requests.Article
{
    public class UpdateArticleRequest
    {
        public string? Headline { get; set; } = default!;
        public string? Subheadline { get; set; } = default!;
        public string? ShortText { get; set; } = default!;
        public string? Text { get; set; } = default!;
        public DateTime? PublishedAt { get; set; }
        public bool? Active { get; set; }
        public bool? HideFullName { get; set; }
        public bool? BreakingNews { get; set; }
        public bool? Live { get; set; }
        public int? CategoryId { get; set; }
        public int? SubcategoryId { get; set; }
        public int? UserId { get; set; }
        public IFormFile? MainPhoto { get; set; }
        public List<IFormFile>? AdditionalPhotos { get; set; } = default!;
        public List<string>? ExistingAdditionalPhotoPaths { get; set; }
    }
}

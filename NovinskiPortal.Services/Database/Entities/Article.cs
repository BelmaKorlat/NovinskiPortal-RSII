namespace NovinskiPortal.Services.Database.Entities
{
    public class Article
    {
        public int Id { get; set; }
        public string Headline { get; set; } = default!;
        public string Subheadline { get; set; } = default!;
        public string ShortText { get; set; } = default!;
        public string Text { get; set; } = default!;
        public DateTime CreatedAt { get; set; }
        public DateTime PublishedAt { get; set; }
        public bool Active { get; set; }
        public string MainPhotoPath { get; set; } = default!;
        public bool HideFullName { get; set; }
        public bool BreakingNews { get; set; }
        public bool Live { get; set; }
        public int CategoryId { get; set; }
        public virtual Category Category { get; set; } = default!;
        public int SubcategoryId { get; set; }
        public virtual Subcategory Subcategory { get; set; } = default!;
        public int UserId { get; set; }
        public virtual User User { get; set; } = default!;
        public virtual ICollection<ArticlePhoto> ArticlePhotos { get; set; } = default!;
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    }
}

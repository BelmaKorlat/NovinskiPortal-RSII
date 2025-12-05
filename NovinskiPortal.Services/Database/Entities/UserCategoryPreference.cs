namespace NovinskiPortal.Services.Database.Entities
{
    public class UserCategoryPreference
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User User { get; set; } = default!;

        public int CategoryId { get; set; }
        public Category Category { get; set; } = default!;

        public int? SubcategoryId { get; set; }
        public Subcategory? Subcategory { get; set; }

        public int ViewCount { get; set; }
        public DateTime LastViewedAt { get; set; }
    }
}

namespace NovinskiPortal.Services.Database.Entities
{
    public class Favorite
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = default!;

        public int ArticleId { get; set; }
        public Article Article { get; set; } = default!;

        public DateTime CreatedAt { get; set; }

    }
}

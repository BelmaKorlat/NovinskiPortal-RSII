namespace NovinskiPortal.Services.Database.Entities
{
    public class ArticleViewLog
    {
        public int Id { get; set; }
        public int ArticleId { get; set; }
        public Article Article { get; set; } = default!;
        public int? UserId { get; set; }
        public User? User { get; set; }
        public DateTime ViewedAtUtc { get; set; }
    }
}

namespace NovinskiPortal.Services.Database.Entities
{
    public class ArticlePhoto
    {
        public int Id { get; set; }
        public string PhotoPath { get; set; } = default!;
        public int ArticleId { get; set; }
        public virtual Article Article { get; set; } = default!;
    }
}

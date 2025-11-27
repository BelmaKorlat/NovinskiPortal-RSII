namespace NovinskiPortal.Services.Database.Entities
{
    public class ArticleCommentVote
    {
        public int Id { get; set; }

        public int ArticleCommentId { get; set; }
        public ArticleComment ArticleComment { get; set; } = default!;

        public int UserId { get; set; }
        public User User { get; set; } = default!;

        // 1 = like, -1 = dislike
        public int Value { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}

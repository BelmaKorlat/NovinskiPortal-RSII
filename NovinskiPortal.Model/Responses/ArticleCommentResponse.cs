

namespace NovinskiPortal.Model.Responses
{
    public class ArticleCommentResponse
    {
        public int Id { get; set; }

        public int ArticleId { get; set; }

        public int UserId { get; set; }
        public string Username { get; set; } = default!;

        public int? ParentCommentId { get; set; }

        public string Content { get; set; } = default!;

        public DateTime CreatedAt { get; set; }

        public int LikesCount { get; set; }
        public int DislikesCount { get; set; }

        public int ReportsCount { get; set; }

        public bool IsOwner { get; set; }

        public int? userVote { get; set; }
    }
}

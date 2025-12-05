namespace NovinskiPortal.Services.Database.Entities
{
    public class ArticleComment
    {
        public int Id { get; set; }

        public int ArticleId { get; set; }
        public Article Article { get; set; } = default!;

        public int UserId { get; set; }
        public User User { get; set; } = default!;

        public int? ParentCommentId { get; set; }
        public ArticleComment? ParentComment { get; set; } = default!;

        public string Content { get; set; } = default!;

        public DateTime CreatedAt { get; set; }

        public bool IsHidden { get; set; } 
        public bool IsDeleted { get; set; }  

        public int LikesCount { get; set; }
        public int DislikesCount { get; set; }
        public int ReportsCount { get; set; } 

        public ICollection<ArticleCommentVote> Votes { get; set; } = new List<ArticleCommentVote>();
        public ICollection<ArticleCommentReport> Reports { get; set; } = new List<ArticleCommentReport>();
    }
}

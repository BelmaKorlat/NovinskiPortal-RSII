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

        public bool IsHidden { get; set; }   // admin sakrio komentar
        public bool IsDeleted { get; set; }  // soft delete

        public int LikesCount { get; set; }
        public int DislikesCount { get; set; }
        public int ReportsCount { get; set; } // koliko je puta komentar prijavljen. Obično je to ukupan broj prijava, ne samo pending. To adminu daje ideju koliko je komentar "problematičan".

        public ICollection<ArticleCommentVote> Votes { get; set; } = new List<ArticleCommentVote>();
        public ICollection<ArticleCommentReport> Reports { get; set; } = new List<ArticleCommentReport>();
    }
}

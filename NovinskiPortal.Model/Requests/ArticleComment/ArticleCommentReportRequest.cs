

namespace NovinskiPortal.Model.Requests.ArticleComment
{
    public class ArticleCommentReportRequest
    {
        public int CommentId { get; set; }

        public string Reason { get; set; } = default!;
    }
}

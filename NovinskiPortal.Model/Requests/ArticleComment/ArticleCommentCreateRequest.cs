
namespace NovinskiPortal.Model.Requests.ArticleComment
{
    public class ArticleCommentCreateRequest
    {
        public string Content { get; set; } = string.Empty;

        public int? ParentCommentId { get; set; }
    }
}

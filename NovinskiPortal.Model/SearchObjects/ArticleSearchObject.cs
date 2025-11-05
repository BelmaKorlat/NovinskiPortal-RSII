
namespace NovinskiPortal.Model.SearchObjects
{
    public class ArticleSearchObject: BaseSearchObject
    {
        public int? CategoryId { get; set; }
        public int? SubcategoryId { get; set; }
        public int? UserId { get; set; }
    }
}

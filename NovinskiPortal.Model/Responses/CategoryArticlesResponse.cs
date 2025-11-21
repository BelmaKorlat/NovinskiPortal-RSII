
namespace NovinskiPortal.Model.Responses
{
    public class CategoryArticlesResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string Color { get; set; } = default!;
        public List<ArticleResponse> Articles { get; set; } = new();
    }
}

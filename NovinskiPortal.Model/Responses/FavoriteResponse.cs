
namespace NovinskiPortal.Model.Responses
{
    public class FavoriteResponse
    {
        public int Id { get; set; }

        public int ArticleId { get; set; }

        public DateTime CreatedAt { get; set; }

        public ArticleResponse Article { get; set; } = default!;
    }
}

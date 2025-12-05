using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.RecommendationService
{
    public interface IRecommendationService
    {
        Task<List<ArticleResponse>> GetPersonalizedAsync(int userId, int take = 10);
    }
}

using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.FavoriteService
{
    public interface IFavoriteService
    {
        Task<bool> AddAsync(int userId, int articleId);
        Task<bool> RemoveAsync(int userId, int articleId);
        Task<bool> IsFavoriteAsync(int userId, int articleId);
        Task<List<FavoriteResponse>> GetAsync(int userId);

    }
}

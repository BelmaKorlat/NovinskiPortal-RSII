using Mapster;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;

namespace NovinskiPortal.Services.Services.FavoriteService
{
    public class FavoriteService: IFavoriteService
    {
        private readonly NovinskiPortalDbContext _context;
        public FavoriteService(NovinskiPortalDbContext context)
        {
            _context = context;
        }

        public async Task<List<FavoriteResponse>> GetAsync(int userId)
        {
            var query = _context.Favorites
                .Where(f => f.UserId == userId)
                .OrderByDescending(f => f.CreatedAt)
                .ProjectToType<FavoriteResponse>();

            var result = await query.ToListAsync();
            return result;
        }
        public async Task<bool> AddAsync(int userId, int articleId)
        {
           var exists = await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.ArticleId == articleId);

            if (exists)
                return false; 

            var favorite = new Favorite
            {
                UserId = userId,
                ArticleId = articleId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Favorites.Add(favorite);
            await _context.SaveChangesAsync();
            return true;
      
        }

        public async Task<bool> RemoveAsync(int userId, int articleId)
        {
            var favorite = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ArticleId == articleId);

            if (favorite == null)
                return false;

            _context.Favorites.Remove(favorite); 
           await _context.SaveChangesAsync();
           return true;
        }

        public async Task<bool> IsFavoriteAsync(int userId, int articleId)
        {
            return await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.ArticleId == articleId);
        }
    }
}

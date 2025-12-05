using MapsterMapper;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace NovinskiPortal.Services.Services.RecommendationService
{
    public class RecommendationService : IRecommendationService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;
        public RecommendationService(NovinskiPortalDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<ArticleResponse>> GetPersonalizedAsync(int userId, int take = 10)
        {
            var topCategories = await _context.UserCategoryPreferences
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.ViewCount)
                .Select(x => x.CategoryId)
                .Take(3)
                .ToListAsync();

            if (!topCategories.Any())
            {
                var fallback = await _context.Articles
                    .Include(a => a.Category)
                    .Include(a => a.Subcategory)
                    .Include(a => a.User)
                    .Include(a => a.Statistics)
                    .Where(a => a.Active)
                    .OrderByDescending(a => a.PublishedAt)
                    .Take(take)
                    .ToListAsync();

                return _mapper.Map<List<ArticleResponse>>(fallback);
            }

            var viewedArticleIds = await _context.UserArticleViews
                .Where(v => v.UserId == userId)
                .Select(v => v.ArticleId)
                .Distinct()
                .ToListAsync();

            var query = _context.Articles
                .Include(a => a.Category)
                .Include(a => a.Subcategory)
                .Include(a => a.User)
                .Include(a => a.Statistics)
                .Where(a => a.Active)
                .Where(a => topCategories.Contains(a.CategoryId));

            if (viewedArticleIds.Any())
            {
                query = query.Where(a => !viewedArticleIds.Contains(a.Id));
            }

            var articles = await query
                .OrderByDescending(a => a.PublishedAt)
                .ThenByDescending(a => a.Statistics != null ? a.Statistics.TotalViews : 0)
                .Take(take)
                .ToListAsync();

            return _mapper.Map<List<ArticleResponse>>(articles);
        }
    }
}


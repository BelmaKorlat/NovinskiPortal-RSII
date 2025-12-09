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

        public async Task<List<ArticleResponse>> GetPersonalizedAsync(int userId, int take = 6)
        {
            var allArticles = await _context.Articles
                .Include(a => a.Category)
                .Include(a => a.Subcategory)
                .Include(a => a.User)
                .Include(a => a.Statistics)
                .Where(a => a.Active)
                .OrderByDescending(a => a.PublishedAt)
                .ThenByDescending(a => a.Statistics != null ? a.Statistics.TotalViews : 0)
                .Take(500)
                .ToListAsync();

            if (!allArticles.Any())
            {
                return new List<ArticleResponse>();
            }

            var prefsRaw = await _context.UserCategoryPreferences
                .Where(x => x.UserId == userId)
                .ToListAsync();

            if (!prefsRaw.Any())
            {
                var globalTop = allArticles
                    .OrderByDescending(a => a.Statistics != null ? a.Statistics.TotalViews : 0)
                    .ThenByDescending(a => a.PublishedAt)
                    .Take(take)
                    .ToList();

                return _mapper.Map<List<ArticleResponse>>(globalTop);
            }

            var prefs = prefsRaw
                .GroupBy(c => c.CategoryId)
                .Select(g => new
                {
                    CategoryId = g.Key,
                    ViewCount = g.Sum(x => x.ViewCount)
                })
                .ToList();

            var totalViews = prefs.Sum(x => x.ViewCount);
            if (totalViews <= 0)
            {
                totalViews = 1;
            }

            var categoryWeights = prefs.ToDictionary(
                x => x.CategoryId,
                x => (double)x.ViewCount / totalViews 
            );

            var viewedIds = await _context.UserArticleViews
                .Where(v => v.UserId == userId)
                .Select(v => v.ArticleId)
                .Distinct()
                .ToListAsync();
            var viewedSet = new HashSet<int>(viewedIds);

            var now = DateTime.UtcNow;
            var maxViews = allArticles.Max(a => a.Statistics?.TotalViews ?? 0);
            if (maxViews <= 0)
            {
                maxViews = 1;
            }

            var rnd = new Random();

            var scoredArticles = allArticles
                .Select(a =>
                {
                    categoryWeights.TryGetValue(a.CategoryId, out var categoryWeight);
                    var contentScore = categoryWeight;

                    var views = a.Statistics?.TotalViews ?? 0;
                    var popularityScore = (double)views / maxViews;

                    var daysAgo = (now - a.PublishedAt).TotalDays;
                    if (daysAgo < 0)
                    {
                        daysAgo = 0;
                    }
                    var recencyScore = 1.0 / (1.0 + daysAgo / 7.0);

                    var viewedPenalty = viewedSet.Contains(a.Id) ? 0.4 : 1.0;

                    var noise = rnd.NextDouble() * 0.05;

                    var finalScore =
                        (0.6 * contentScore + 0.25 * popularityScore + 0.15 * recencyScore)
                        * viewedPenalty
                        + noise;

                    return new
                    {
                        Article = a,
                        Score = finalScore
                    };
                })
                .OrderByDescending(x => x.Score)
                .Select(x => x.Article)
                .ToList();

            var result = scoredArticles.Take(take).ToList();

            if (result.Count < take)
            {
                var existingIds = result.Select(a => a.Id).ToHashSet();

                var extra = allArticles
                    .Where(a => !existingIds.Contains(a.Id))
                    .OrderByDescending(a => a.Statistics != null ? a.Statistics.TotalViews : 0)
                    .ThenByDescending(a => a.PublishedAt)
                    .Take(take - result.Count)
                    .ToList();

                result.AddRange(extra);
            }

            return _mapper.Map<List<ArticleResponse>>(result);
        }


    }
}


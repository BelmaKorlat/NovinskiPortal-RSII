using NovinskiPortal.Model.Responses;

namespace NovinskiPortal.Services.Services.AdminDashboardService
{
    public interface IAdminDashboardService
    {
        Task<AdminDashboardSummaryResponse> GetSummaryAsync();
        Task<List<TopArticleDashboardResponse>> GetTopArticlesAsync(int? categoryId, DateTime? from, DateTime? to, int tako = 15);
        Task<byte[]> GenerateTopArticlesPdfAsync(int? categoryId, DateTime? from, DateTime? to, int take = 15);
        Task<byte[]> GenerateCategoryViewsLast30DaysPdfAsync();
    }
}

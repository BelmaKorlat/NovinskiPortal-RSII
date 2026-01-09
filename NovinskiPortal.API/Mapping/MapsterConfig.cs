using Mapster;
using NovinskiPortal.Common.Enumerations;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database.Entities;

namespace NovinskiPortal.API.Mapping
{
    public static class MapsterConfig
    {
        public static void RegisterMappings(TypeAdapterConfig config)
        {
            config.NewConfig<Subcategory, SubcategoryResponse>()
                .Map(dest => dest.CategoryName, src => src.Category.Name);

            config.NewConfig<User, UserAdminResponse>()
                .Map(dest => dest.RoleName, src => src.Role.Name)
                .Map(dest => dest.CreatedAt, src => DateTime.SpecifyKind(src.CreatedAt, DateTimeKind.Utc))
                .Map(dest => dest.LastLoginAt,
                    src => src.LastLoginAt == null || src.LastLoginAt == default
                        ? (DateTime?)null
                        : DateTime.SpecifyKind(src.LastLoginAt.Value, DateTimeKind.Utc));

            config.NewConfig<User, UserResponse>()
                .Map(dest => dest.RoleName, src => src.Role.Name);

            config.NewConfig<Article, ArticleResponse>()
                .Map(d => d.CreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
                .Map(d => d.PublishedAt, s => DateTime.SpecifyKind(s.PublishedAt, DateTimeKind.Utc))
                .Map(d => d.Category, s => s.Category.Name)
                .Map(d => d.Subcategory, s => s.Subcategory.Name)
                .Map(d => d.User, s => s.HideFullName ? s.User.Nick : s.User.FirstName + " " + s.User.LastName)
                .Map(d => d.Color, s => s.Category.Color)
                .Map(d => d.CommentsCount, s => s.ArticleComments.Count(c => !c.IsDeleted && !c.IsHidden));

            config.NewConfig<Article, ArticleDetailResponse>()
                .Map(d => d.CreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
                .Map(d => d.PublishedAt, s => DateTime.SpecifyKind(s.PublishedAt, DateTimeKind.Utc))
                .Map(d => d.Category, s => s.Category.Name)
                .Map(d => d.Subcategory, s => s.Subcategory.Name)
                .Map(d => d.User, s => s.HideFullName ? s.User.Nick : s.User.FirstName + " " + s.User.LastName)
                .Map(d => d.Color, s => s.Category.Color)
                .Map(d => d.AdditionalPhotos, s => s.ArticlePhotos.Select(p => p.PhotoPath).ToList())
                .Map(d => d.CommentsCount, s => s.ArticleComments.Count(c => !c.IsDeleted && !c.IsHidden));

            config.NewConfig<Favorite, FavoriteResponse>()
                .Map(d => d.Id, s => s.Id)
                .Map(d => d.CreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
                .Map(d => d.Article, s => s.Article);

            config.NewConfig<NewsReport, NewsReportResponse>()
                .Map(d => d.UserFullName, s => s.User != null ? s.User.FirstName + " " + s.User.LastName : null)
                .Map(d => d.CreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
                .Map(d => d.ProcessedAt, s => s.ProcessedAt.HasValue
                    ? DateTime.SpecifyKind(s.ProcessedAt.Value, DateTimeKind.Utc)
                    : (DateTime?)null);

            config.NewConfig<ArticleComment, ArticleCommentResponse>()
                .Map(d => d.Username, s => s.User != null ? s.User.Username : null)
                .Map(d => d.CreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc));

            config.NewConfig<ArticleComment, AdminCommentReportResponse>()
                .Map(d => d.ArticleHeadline, s => s.Article.Headline)
                .Map(d => d.CommentAuthorId, s => s.UserId)
                .Map(d => d.CommentAuthorUsername, s => s.User.Username)
                .Map(d => d.ReportsCount, s => s.ReportsCount)
                .Map(d => d.PendingReportsCount, s => s.Reports == null ? 0 : s.Reports.Count(r => r.Status == ArticleCommentReportStatus.Pending))
                .Map(d => d.FirstReportedAt, s => s.Reports == null || !s.Reports.Any()
                    ? (DateTime?)null
                    : DateTime.SpecifyKind(s.Reports.Min(r => r.CreatedAt), DateTimeKind.Utc))
                .Map(d => d.LastReportedAt, s => s.Reports == null || !s.Reports.Any()
                    ? (DateTime?)null
                    : DateTime.SpecifyKind(s.Reports.Max(r => r.CreatedAt), DateTimeKind.Utc))
                .Map(d => d.HasPendingReports, s => s.Reports != null && s.Reports.Any(r => r.Status == ArticleCommentReportStatus.Pending));

            config.NewConfig<ArticleComment, AdminCommentDetailReportResponse>()
                .Map(d => d.ArticleHeadline, s => s.Article.Headline)
                .Map(d => d.CommentAuthorId, s => s.UserId)
                .Map(d => d.CommentAuthorUsername, s => s.User.Username)
                .Map(d => d.CommentCreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
                .Map(d => d.ReportsCount, s => s.ReportsCount)
                .Map(d => d.PendingReportsCount, s => s.Reports != null ? s.Reports.Count(r => r.Status == ArticleCommentReportStatus.Pending) : 0)
                .Map(d => d.FirstReportedAt, s => s.Reports != null && s.Reports.Count > 0
                    ? DateTime.SpecifyKind(s.Reports.Min(r => r.CreatedAt), DateTimeKind.Utc)
                    : (DateTime?)null)
                .Map(d => d.LastReportedAt, s => s.Reports != null && s.Reports.Count > 0
                    ? DateTime.SpecifyKind(s.Reports.Max(r => r.CreatedAt), DateTimeKind.Utc)
                    : (DateTime?)null)
                .Map(d => d.AuthorCommentBanUntil, s => s.User.CommentBanUntil == null
                    ? (DateTime?)null
                    : DateTime.SpecifyKind(s.User.CommentBanUntil.Value, DateTimeKind.Utc))
                .Map(d => d.AuthorCommentBanReason, s => s.User.CommentBanReason)
                .Map(d => d.Reports, s => (s.Reports ?? new List<ArticleCommentReport>())
                    .OrderByDescending(r => r.CreatedAt)
                    .Adapt<List<AdminCommentItemReportResponse>>());

            config.NewConfig<ArticleCommentReport, AdminCommentItemReportResponse>()
                .Map(d => d.ReporterUsername, s => s.ReporterUser.Username)
                .Map(d => d.CreatedAt, s => DateTime.SpecifyKind(s.CreatedAt, DateTimeKind.Utc))
                .Map(d => d.ProcessedAt, s => s.ProcessedAt.HasValue
                    ? DateTime.SpecifyKind(s.ProcessedAt.Value, DateTimeKind.Utc)
                    : (DateTime?)null)
                .Map(d => d.ProcessedByAdminUsername, s => s.ProcessedByAdmin != null ? s.ProcessedByAdmin.Username : null);
        }
    }
}

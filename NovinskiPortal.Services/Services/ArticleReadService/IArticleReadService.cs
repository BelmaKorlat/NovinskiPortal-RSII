namespace NovinskiPortal.Services.Services.ArticleReadService
{
    public interface IArticleReadService
    {
        Task TrackViewAsync(int articleId, int? userId);
    }
}

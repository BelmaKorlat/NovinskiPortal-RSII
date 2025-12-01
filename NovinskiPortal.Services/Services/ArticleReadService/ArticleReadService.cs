using NovinskiPortal.Common.Messaging;
using NovinskiPortal.Services.Services.ArticleReadService;

namespace NovinskiPortal.Services.Implementations
{
    public class ArticleReadService : IArticleReadService
    {
        private readonly IEventPublisher _publisher;

        public ArticleReadService(IEventPublisher publisher)
        {
            _publisher = publisher;
        }

        public async Task TrackViewAsync(int articleId, int? userId)
        {
            var evt = new ArticleViewedEvent
            {
                ArticleId = articleId,
                UserId = userId,
                ViewedAtUtc = DateTime.UtcNow
            };

            await _publisher.PublishArticleViewedAsync(evt);
        }
    }
}

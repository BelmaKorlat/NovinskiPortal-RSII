using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovinskiPortal.Common.Messaging
{
    public interface IEventPublisher
    {
        Task PublishArticleViewedAsync(ArticleViewedEvent @event);
    }
}

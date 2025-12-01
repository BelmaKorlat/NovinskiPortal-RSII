using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovinskiPortal.Services.Services.ArticleReadService
{
    public interface IArticleReadService
    {
        Task TrackViewAsync(int articleId, int? userId);
    }
}

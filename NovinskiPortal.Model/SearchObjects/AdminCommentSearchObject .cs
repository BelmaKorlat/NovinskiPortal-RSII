using NovinskiPortal.Common.Enumerations;

namespace NovinskiPortal.Model.SearchObjects
{
    public class AdminCommentReportSearchObject : BaseSearchObject
    {
        public ArticleCommentReportStatus? Status { get; set; }
    }
}

using NovinskiPortal.Model.Requests.AdminComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.AdminCommentService
{
    public interface IAdminCommentService : IService<AdminCommentReportResponse, AdminCommentReportSearchObject>
    {
        Task<AdminCommentDetailReportResponse?> GetDetailAsync(int commentId);
        Task<bool> HideAsync(int id, int adminUserId);

        Task<bool> SoftDeleteAsync(int id, int adminUserId);
        Task<bool> RejectPendingReportsAsync(int commentId, int adminUserId, string? adminNote);
        Task<bool> BanAuthorAsync(int commentId, BanCommentAuthorRequest request);
        Task<int> GetPendingCountAsync();

    }
}

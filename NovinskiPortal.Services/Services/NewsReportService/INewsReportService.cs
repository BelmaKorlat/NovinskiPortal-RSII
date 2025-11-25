using NovinskiPortal.Model.Requests.NewsReport;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.NewsReportService
{
    public interface INewsReportService : IService<NewsReportResponse, NewsReportSearchObject>
    {
        Task<NewsReportResponse> CreateAsync(CreateNewsReportRequest request, int? userId);
        Task<NewsReportResponse?> UpdateStatusAsync(int id, UpdateNewsReportStatusRequest request);
    }
}

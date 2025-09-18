using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;

namespace NovinskiPortal.Services.IServices
{
    public interface IService<T, TSearch> 
        where T : class 
        where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}

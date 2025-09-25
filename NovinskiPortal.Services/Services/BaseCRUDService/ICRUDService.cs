using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.BaseCRUDService
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch>
         where T : class
         where TSearch : BaseSearchObject
         where TInsert : class
         where TUpdate : class
    {
        Task<T> CreateAsync(TInsert request);
        Task<T> UpdateAsync(int id, TUpdate request);
        Task<bool> DeleteAsync(int id);

    }
}

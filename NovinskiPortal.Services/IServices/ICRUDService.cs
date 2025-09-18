using NovinskiPortal.Model.SearchObjects;

namespace NovinskiPortal.Services.IServices
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

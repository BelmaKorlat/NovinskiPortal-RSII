using NovinskiPortal.Model.Requests.Category;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;

namespace NovinskiPortal.Services.IServices
{
    public interface ICategoryService : ICRUDService<CategoryResponse, CategorySearchObject, CreateCategoryRequest, UpdateCategoryRequest>
    {
        Task<List<CategoryMenuResponse>> GetCategoriesMenuAsync();
        Task<CategoryResponse?> ToggleCategoryStatusAsync(int id);
    }
}

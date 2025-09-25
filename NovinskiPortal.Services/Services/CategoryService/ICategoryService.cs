using NovinskiPortal.Model.Requests.Category;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.CategoryService.CategoryService
{
    public interface ICategoryService : ICRUDService<CategoryResponse, CategorySearchObject, CreateCategoryRequest, UpdateCategoryRequest>
    {
        Task<List<CategoryMenuResponse>> GetCategoriesMenuAsync();
        Task<CategoryResponse?> ToggleCategoryStatusAsync(int id);
    }
}

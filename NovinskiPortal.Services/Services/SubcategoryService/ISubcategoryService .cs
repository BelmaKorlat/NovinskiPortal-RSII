using NovinskiPortal.Model.Requests.Subcategory;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseCRUDService;


namespace NovinskiPortal.Services.Services.SubcategoryService.SubcategoryService
{
    public interface ISubcategoryService : ICRUDService<SubcategoryResponse, SubcategorySearchObject, CreateSubcategoryRequest, UpdateSubcategoryRequest>
    {
        Task<SubcategoryResponse?> ToggleSubcategoryStatusAsync(int id);
    }
}

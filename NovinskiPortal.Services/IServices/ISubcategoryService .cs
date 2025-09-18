using NovinskiPortal.Model.Requests.Subcategory;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;


namespace NovinskiPortal.Services.IServices
{
    public interface ISubcategoryService : ICRUDService<SubcategoryResponse, SubcategorySearchObject, CreateSubcategoryRequest, UpdateSubcategoryRequest>
    {
        Task<SubcategoryResponse?> ToggleSubcategoryStatusAsync(int id);
    }
}

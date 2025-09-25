using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.Subcategory;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.SubcategoryService.SubcategoryService;

namespace NovinskiPortal.API.Controllers
{
    public class SubcategoriesController : BaseCRUDController<SubcategoryResponse, SubcategorySearchObject, CreateSubcategoryRequest, UpdateSubcategoryRequest>
    {
        protected readonly ISubcategoryService _subcategoryService;

        public SubcategoriesController(ISubcategoryService subcategoryService) : base(subcategoryService)
        {
            _subcategoryService = subcategoryService;
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> ToggleStatusSubcategoryAsync(int id)
        {
            var subcategoryDto = await _subcategoryService.ToggleSubcategoryStatusAsync(id);
            return subcategoryDto is null ? NotFound() : Ok(subcategoryDto);
        }
        public override async Task<SubcategoryResponse> Create([FromBody] CreateSubcategoryRequest createSubcategoryRequest)
        {
            return await _subcategoryService.CreateAsync(createSubcategoryRequest);
        }

        public override async Task<SubcategoryResponse> Update(int id, [FromBody] UpdateSubcategoryRequest updateSubcategoryRequest)
        {
            return await _subcategoryService.UpdateAsync(id, updateSubcategoryRequest);
        }

        public override async Task<bool> Delete(int id)
        {
            return await _subcategoryService.DeleteAsync(id);
        }

    }
}

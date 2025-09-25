
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.Category;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.CategoryService.CategoryService;

namespace NovinskiPortal.API.Controllers
{
    public class CategoriesController : BaseCRUDController<CategoryResponse, CategorySearchObject, CreateCategoryRequest, UpdateCategoryRequest>
    {
        protected readonly ICategoryService _categoryService;
        public CategoriesController(ICategoryService categoryService) : base(categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet("categories-menu")]
        public async Task<IActionResult> GetCategoriesMenuAsync()
        {
            return Ok(await _categoryService.GetCategoriesMenuAsync());
        }

        /*[HttpPatch("{id}/status")]
        public async Task<IActionResult> ToggleCategoryStatusAsync(int id, UpdateCategoryStatusRequest updateCategoryStatusRequest)
        {
            var category = await categoryService.ToggleCategoryStatusAsync(id, updateCategoryStatusRequest);
            return category is null ? NotFound() : Ok();
        }*/

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> ToggleCategoryStatusAsync(int id)
        {
            var categoryDto = await _categoryService.ToggleCategoryStatusAsync(id);
            return categoryDto is null ? NotFound() : Ok(categoryDto);
        }
        public override async Task<CategoryResponse> Create([FromBody] CreateCategoryRequest createCategoryRequest)
        {
            return await _categoryService.CreateAsync(createCategoryRequest);
        }

        public override async Task<CategoryResponse> Update(int id, [FromBody] UpdateCategoryRequest updateCategoryRequest)
        {
            return await _categoryService.UpdateAsync(id, updateCategoryRequest);
        }

        public override async Task<bool> Delete(int id)
        {
            return await _categoryService.DeleteAsync(id);
        }

    }
}

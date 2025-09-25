using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.Category;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.CategoryService.CategoryService
{
    public class CategoryService : BaseCRUDService<CategoryResponse, CategorySearchObject, Category, CreateCategoryRequest, UpdateCategoryRequest>, ICategoryService
    {
        private readonly NovinskiPortalDbContext _context;

        public CategoryService(NovinskiPortalDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public async Task<List<CategoryMenuResponse>> GetCategoriesMenuAsync()
        {
            return await _context.Categories
                .Where(c => c.Active == true)
                .Select(c => new CategoryMenuResponse
                {
                    Id = c.Id,
                    Name = c.Name,
                    Color = c.Color,
                    Subcategories = _context.Subcategories
                        .Where(s => s.Active == true && s.CategoryId == c.Id)
                        .Select(s => new SubcategoryMenuResponse
                        {
                            Id = s.Id,
                            Name = s.Name
                        }).ToList()
                }).ToListAsync();
        }
        public async Task<CategoryResponse?> ToggleCategoryStatusAsync(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category is null)  return null;

            category.Active = !category.Active;

            await _context.SaveChangesAsync();
            return _mapper.Map<CategoryResponse>(category);
        }

        protected override IQueryable<Category> ApplyFilter(IQueryable<Category> query, CategorySearchObject search)
        {
            if (search.Active.HasValue)
            {
                query = query.Where(c => c.Active == search.Active.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(c => c.Name.Contains(search.FTS));
            }
            return query;
        }

        protected override IOrderedQueryable<Category> ApplyOrder(IQueryable<Category> query, CategorySearchObject search)
        {
            return query.OrderByDescending(q => q.OrdinalNumber).ThenByDescending(c => c.Id);
        }

    }

}

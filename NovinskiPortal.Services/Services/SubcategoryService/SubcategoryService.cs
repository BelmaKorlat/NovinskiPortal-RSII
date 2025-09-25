using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.Subcategory;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.SubcategoryService.SubcategoryService
{
    public class SubcategoryService : BaseCRUDService<SubcategoryResponse, SubcategorySearchObject, Subcategory, CreateSubcategoryRequest, UpdateSubcategoryRequest>, ISubcategoryService
    {
        private readonly NovinskiPortalDbContext _context;

        public SubcategoryService(NovinskiPortalDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }
        public async Task<SubcategoryResponse?> ToggleSubcategoryStatusAsync(int id)
        {
            var subcategory = await _context.Subcategories.FindAsync(id);
            if (subcategory is null)
                return null;

            subcategory.Active = !subcategory.Active;

            await _context.SaveChangesAsync();
            return _mapper.Map<SubcategoryResponse>(subcategory);
        }

        protected override IQueryable<Subcategory> ApplyFilter(IQueryable<Subcategory> query, SubcategorySearchObject search)
        {
            if (search.CategoryId.HasValue)
            {
                query = query.Where(s => s.CategoryId == search.CategoryId.Value);
            }

            if (search.Active.HasValue)
            {
                query = query.Where(s => s.Active == search.Active.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(s => s.Name.Contains(search.FTS));
            }
            return query;
        }

        protected override IOrderedQueryable<Subcategory>? ApplyOrder(IQueryable<Subcategory> query, SubcategorySearchObject search)
        {
            return query.OrderByDescending(q => q.OrdinalNumber).ThenByDescending(s => s.Id);
        }

        protected override IQueryable<Subcategory> ApplyIncludes(IQueryable<Subcategory> query)
        {
            return query.Include(s => s.Category);
        }

    }
}

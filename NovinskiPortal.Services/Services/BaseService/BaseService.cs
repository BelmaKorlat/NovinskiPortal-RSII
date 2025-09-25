using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;


namespace NovinskiPortal.Services.Services.BaseService
{
    public class BaseService<T, TSearch, TEntity> : IService<T, TSearch>
        where T : class
        where TSearch : BaseSearchObject
        where TEntity : class
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;
        public BaseService(NovinskiPortalDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<PagedResult<T>> GetAsync(TSearch search)
        {
            var query = _context.Set<TEntity>().AsQueryable();
            query = ApplyFilter(query, search);
            query = ApplyOrder(query, search) ?? query;
            query = ApplyIncludes(query);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }
             
            if (!search.RetrieveAll)
            {
                var page = Math.Max(search.Page ?? 0, 0);                 // default 0
                var size = Math.Clamp(search.PageSize ?? 10, 1, 200);     // default 10, granice 1..200

                query = query.Skip(page * size).Take(size);
            }

            var list = await query.ToListAsync();
            return new PagedResult<T>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }
        protected virtual IOrderedQueryable<TEntity>? ApplyOrder(IQueryable<TEntity> query, TSearch search)
        {
            return null;
        }

        protected virtual IQueryable<TEntity> ApplyIncludes(IQueryable<TEntity> query)
        {
            return query;
        }
        public virtual async Task<T?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
            {
                return null;
            }
            return MapToResponse(entity);
        }

        public virtual T MapToResponse(TEntity entity)
        {
            return _mapper.Map<T>(entity);
        }
    }
}

using MapsterMapper;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.BaseCRUDService
{
    public abstract class BaseCRUDService<T, TSearch, TEntity, TInsert, TUpdate> :
         BaseService<T, TSearch, TEntity>,
         ICRUDService<T, TSearch, TInsert, TUpdate>
         where T : class
         where TSearch : BaseSearchObject
         where TEntity : class, new()
         where TInsert : class
         where TUpdate : class
    {
        private readonly NovinskiPortalDbContext _context;
        protected readonly IMapper _mapper;

        public BaseCRUDService(NovinskiPortalDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // u BaseCRUDService<TResp, TSearch, TEntity, TCreate, TUpdate>
        protected virtual Task AfterInsertAsync(TEntity entity) => Task.CompletedTask;

        public virtual async Task<T> CreateAsync(TInsert request)
        {
              var entity = new TEntity();
            MapToEntityInsert(entity, request);
            _context.Set<TEntity>().Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();

            await AfterInsertAsync(entity);

            return MapToResponse(entity);
        }

        protected virtual Task BeforeInsert(TEntity entity, TInsert request)
            => Task.CompletedTask;
        protected virtual TEntity MapToEntityInsert(TEntity entity, TInsert request)
        {
            return _mapper.Map(request, entity);
        }

        public virtual async Task<T> UpdateAsync(int id, TUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapToEntityUpdate(entity, request);

            await _context.SaveChangesAsync();
            await AfterInsertAsync(entity);

            return MapToResponse(entity);
        }

        protected virtual Task BeforeUpdate(TEntity entity, TUpdate request)
            => Task.CompletedTask;
        protected virtual void MapToEntityUpdate(TEntity entity, TUpdate request)
        {
            _mapper.Map(request, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return false;

            await BeforeDelete(entity);

            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        protected virtual Task BeforeDelete(TEntity entity)
            => Task.CompletedTask;
    }

}

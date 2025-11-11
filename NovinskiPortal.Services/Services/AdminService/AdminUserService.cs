
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Commom.PasswordService;
using NovinskiPortal.Model.Requests.User;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.AdminService
{
    public class AdminUserService : BaseCRUDService<UserAdminResponse, UserSearchObject, User, CreateUserRequest, UpdateUserRequest>, IAdminUserService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IPasswordService _passwordService;

        public AdminUserService(NovinskiPortalDbContext context, IMapper mapper, IPasswordService passwordService) : base(context, mapper)
        {
            _context = context;
            _passwordService = passwordService;
        }

        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject search)
        {
            query = query.Include(u => u.Role).AsNoTracking();

            // Ako admin želi da vidi i obrisane, skloni globalni filter
            if (search.IncludeDeleted)
                query = query.IgnoreQueryFilters();

            if (search.Active.HasValue)
            {
                query = query.Where(u => u.Active == search.Active.Value);
            }

            if (search.RoleId.HasValue)
            {
                query = query.Where(u => u.RoleId == search.RoleId.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                var key = search.FTS.Trim().ToLowerInvariant();
                query = query.Where(u => 
                    u.FirstName.ToLower().Contains(key) ||
                    u.LastName.ToLower().Contains(key)  ||
                    u.Username.ToLower().Contains(key)  ||
                    u.Email.ToLower().Contains(key));
            }

            return query;
        }
        protected override async Task BeforeInsert(User entity, CreateUserRequest createUserRequest)
        {
            var username = createUserRequest.Username.Trim();
            var email = createUserRequest.Email.Trim();

            var existUser = await _context.Users.AnyAsync(u =>
                u.Username.ToLower() == username.ToLower() ||
                u.Email.ToLower() == email.ToLower());

            if (existUser)
                throw new InvalidOperationException("Username or email already exists.");

            var salt = _passwordService.GenerateSalt();
            entity.PasswordSalt = salt;
            entity.PasswordHash = _passwordService.HashPassword(createUserRequest.Password, salt);
        }

        protected override User MapToEntityInsert(User entity, CreateUserRequest request)
        {
            entity.FirstName = request.FirstName.Trim();
            entity.LastName = request.LastName.Trim();
            entity.Nick = (request.Nick ?? string.Empty).Trim();
            entity.Username = request.Username.Trim();
            entity.Email = request.Email.Trim();
            entity.RoleId = request.RoleId;
            entity.Active = request.Active;
            return entity;
        }

        protected override async Task BeforeUpdate(User entity, UpdateUserRequest updateUserRequest)
        {
            var username = updateUserRequest.Username.Trim();
            var email = updateUserRequest.Email.Trim();

            var conflict = await _context.Users.AnyAsync(u =>
                u.Id != entity.Id && (u.Username.ToLower() == username.ToLower() || u.Email.ToLower() == email.ToLower()));
            if (conflict)
                throw new InvalidOperationException("Username or email already exists.");

            if (!string.IsNullOrWhiteSpace(updateUserRequest.NewPassword))
            {
                var salt = _passwordService.GenerateSalt();
                entity.PasswordSalt = salt;
                entity.PasswordHash = _passwordService.HashPassword(updateUserRequest.NewPassword, salt);
            }
        }

        protected override void MapToEntityUpdate(User entity, UpdateUserRequest updateUserRequest)
        {
            entity.FirstName = updateUserRequest.FirstName.Trim();
            entity.LastName = updateUserRequest.LastName.Trim();
            entity.Nick = (updateUserRequest.Nick ?? string.Empty).Trim();
            entity.Username = updateUserRequest.Username.Trim();
            entity.Email = updateUserRequest.Email.Trim();
            entity.RoleId = updateUserRequest.RoleId;
            entity.Active = updateUserRequest.Active;
        }

        public async Task<bool> SoftDeleteAsync(int id)
        {
            // Globalni filter krije samo IsDeleted = true, a mi tražimo aktivnog (nije obrisan)
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id);
            if (user is null) return false;

            if (user.IsDeleted) return true; // već “obrisan” – idempotentno

            user.IsDeleted = true;
            // (opciono) korisnik više nije aktivan ako je soft-deleted
            user.Active = false;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RestoreAsync(int id)
        {
            // Pošto je obrisan korisnik sakriven globalnim filterom, moraš ga ignorisati da bi ga našla
            var user = await _context.Users
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user is null) return false;

            if (!user.IsDeleted) return true; // već “aktivan” – idempotentno

            user.IsDeleted = false;
            // (opciono) ne diraj Active, ili ga postavi kako želiš:
             user.Active = true;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<UserAdminResponse?> ChangeRoleAsync(int id, int role)
        {
            var user = await _context.Users.FindAsync(id);
            if (user is null) return null;

            user.RoleId = role;

            await _context.SaveChangesAsync();
            return _mapper.Map<UserAdminResponse>(user);
        }

        public async Task<UserAdminResponse?> ToggleStatusUserAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user is null) return null;

            user.Active = !user.Active;

            await _context.SaveChangesAsync();
            return _mapper.Map<UserAdminResponse>(user);
        }
    }
}

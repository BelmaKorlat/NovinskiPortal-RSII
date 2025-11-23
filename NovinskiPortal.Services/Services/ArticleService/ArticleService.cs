using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.Article;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseCRUDService;

namespace NovinskiPortal.Services.Services.ArticleService
{
    public class ArticleService : BaseCRUDService<ArticleResponse, ArticleSearchObject, Article, CreateArticleRequest, UpdateArticleRequest>, IArticleService
    {
        private readonly NovinskiPortalDbContext _context;

        public ArticleService(NovinskiPortalDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }
        protected override IQueryable<Article> ApplyFilter(IQueryable<Article> query, ArticleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(a =>
                a.Headline.Contains(search.FTS) ||
                a.Subheadline.Contains(search.FTS) ||
                a.Text.Contains(search.FTS) ||
                a.ShortText.Contains(search.FTS));
            }

            if (search.CategoryId.HasValue)
                query = query.Where(a => a.CategoryId == search.CategoryId.Value);

            if (search.SubcategoryId.HasValue)
                query = query.Where(a => a.SubcategoryId == search.SubcategoryId.Value);

            if (search.UserId.HasValue)
                query = query.Where(a => a.UserId == search.UserId.Value);

            // ako je mod "live", filtriraj samo live članke
            if (!string.IsNullOrWhiteSpace(search.Mode) &&
                search.Mode.Equals("live", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(a => a.Live);
            }

            if (!search.IncludeFuture)
            {
                query = query.Where(a => a.PublishedAt <= DateTime.UtcNow && a.Active);
            }

            return query;
        }

        protected override IOrderedQueryable<Article>? ApplyOrder(IQueryable<Article> query, ArticleSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Mode))
            {
                switch (search.Mode.ToLower())
                {
                    case "latest":
                        // najnovije po datumu objave
                        return query.OrderByDescending(a => a.PublishedAt);

                    case "mostread":
                        // za sada isto što i latest, dok ne dodaš ViewCount
                        // kasnije: return query.OrderByDescending(a => a.ViewCount);
                        return query.OrderByDescending(a => a.PublishedAt);

                    case "live":
                        // live članci, opet sortirani po datumu objave
                        return query.OrderByDescending(a => a.PublishedAt);
                }
            }
            // default, ako Mode nije poslan
            return query.OrderByDescending(a => a.PublishedAt);
        }
        protected override IQueryable<Article> ApplyIncludes(IQueryable<Article> query)
        {
            return query
                .Include(a => a.Category)
                .Include(a => a.Subcategory)
                .Include(a => a.User)
                .Include(a => a.ArticlePhotos);
        }

        protected override async Task AfterInsertAsync(Article entity)
        {
            await _context.Entry(entity).Reference(a => a.Category).LoadAsync();
            await _context.Entry(entity).Reference(a => a.Subcategory).LoadAsync();
            await _context.Entry(entity).Reference(a => a.User).LoadAsync();
            await _context.Entry(entity).Collection(a => a.ArticlePhotos).LoadAsync();
        }

        public async Task<List<CategoryArticlesResponse>> GetCategoryArticlesAsync(int perCategory = 5)
        {
            return await _context.Categories
                .Where(c => c.Active)
                .Select(c => new CategoryArticlesResponse
                {
                    Id = c.Id,
                    Name = c.Name,
                    Color = c.Color,

                    Articles = _context.Articles
                        .Where(a => a.Active &&
                                    a.CategoryId == c.Id &&
                                    a.PublishedAt <= DateTime.UtcNow)
                        .OrderByDescending(a => a.PublishedAt)
                        .Take(perCategory)
                        .Select(a => new ArticleResponse
                        {
                            Id = a.Id,
                            Headline = a.Headline,
                            Subheadline = a.Subheadline,
                            CreatedAt = DateTime.SpecifyKind(a.CreatedAt, DateTimeKind.Utc),
                            PublishedAt = DateTime.SpecifyKind(a.PublishedAt, DateTimeKind.Utc),
                            Active = a.Active,
                            HideFullName = a.HideFullName,
                            BreakingNews = a.BreakingNews,
                            Live = a.Live,
                            Category = a.Category.Name,
                            Subcategory = a.Subcategory.Name,
                            User = a.HideFullName ? a.User.Nick : a.User.FirstName + " " + a.User.LastName,          
                            MainPhotoPath = a.MainPhotoPath,
                            Color = a.Category.Color,    
                        })
                        .ToList()
                })
                .ToListAsync();
        }

        public override async Task<ArticleResponse?> GetByIdAsync(int id)
        {
            var entity = await ApplyIncludes(_context.Articles.AsQueryable())
                   .AsNoTracking()
                   .FirstOrDefaultAsync(a => a.Id == id);

            return entity is null ? null : _mapper.Map<ArticleResponse>(entity);
        }

        public async Task<ArticleDetailResponse?> GetDetailByIdAsync(int id)
        {
            var entity = await ApplyIncludes(_context.Articles.AsQueryable())
                   .AsNoTracking()
                   .FirstOrDefaultAsync(a => a.Id == id);

            return entity is null ? null : _mapper.Map<ArticleDetailResponse>(entity);
        }

        public async Task<ArticleResponse?> ToggleArticleStatusAsync(int id)
        {
            var article = await _context.Articles.FindAsync(id);
            if (article is null)
                return null;

            article.Active = !article.Active;

            await _context.SaveChangesAsync();
            await AfterInsertAsync(article);
            return _mapper.Map<ArticleResponse>(article);
        }
       
        protected override Task BeforeInsert(Article entity, CreateArticleRequest request)
        {  
            entity.CreatedAt = DateTime.UtcNow;

            var uploads = EnsureUploadsFolder();

            entity.MainPhotoPath = SavePhoto(request.MainPhoto, uploads);

            if(request.AdditionalPhotos != null && request.AdditionalPhotos.Any())
            {
                entity.ArticlePhotos = new List<ArticlePhoto>();

                foreach (var item in request.AdditionalPhotos)
                {
                    var itemPhotoPath = SavePhoto(item, uploads);
                    entity.ArticlePhotos.Add(new ArticlePhoto
                    {
                        PhotoPath = itemPhotoPath
                    });
                }
            }

           return Task.CompletedTask;
        }

        protected override Task BeforeUpdate(Article entity, UpdateArticleRequest request)
        {
            var uploads = EnsureUploadsFolder();

            if(request.MainPhoto != null)
            {
                DeleteIfExists(entity.MainPhotoPath);
                entity.MainPhotoPath = SavePhoto(request.MainPhoto, uploads);
            }

            if(request.AdditionalPhotos != null && request.AdditionalPhotos.Count > 0)
            {
                entity.ArticlePhotos = new List<ArticlePhoto>();
                foreach (var item in request.AdditionalPhotos)
                {
                    var itemPhotoPath = SavePhoto(item, uploads);
                    entity.ArticlePhotos.Add(new ArticlePhoto
                    {
                        PhotoPath = itemPhotoPath
                    });
                }
            }
            return Task.CompletedTask;
        }

        protected override async Task BeforeDelete(Article entity)
        {
            DeleteIfExists(entity.MainPhotoPath);

            var additionalPhotos = await _context.ArticlePhotos
                .Where(a => a.ArticleId == entity.Id)
                .ToListAsync();

            foreach (var item in additionalPhotos)
            {
                DeleteIfExists(item.PhotoPath);
            }
            _context.ArticlePhotos.RemoveRange(additionalPhotos);
        }
        private void DeleteIfExists(string? webPath)
        {
            if (string.IsNullOrWhiteSpace(webPath))
                return;

            var oldPhotoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", webPath.TrimStart('/'));
            if (File.Exists(oldPhotoPath)) 
                File.Delete(oldPhotoPath);
        }

        private static string SavePhoto(PhotoUpload photo, string uploadsFolder)
        {
            if (photo.Content == null || photo.Content.Length == 0)
                throw new ArgumentException("File is empty.");

            var allowed = new[] { ".jpg", ".jpeg", ".png", ".webp" };

            var photoFileExtension = Path.GetExtension(photo.FileName).ToLowerInvariant();
            if (!allowed.Contains(photoFileExtension))
                throw new InvalidOperationException("Unsupported image type.");

            var photoFileName = $"{Guid.NewGuid()}{photoFileExtension}";
            var photoFilePath = Path.Combine(uploadsFolder, photoFileName);
            File.WriteAllBytes(photoFilePath, photo.Content);

            return $"/Photos/{photoFileName}";
           
        }

        private static string EnsureUploadsFolder()
        {
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Photos");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);
            return uploadsFolder;
        }
     
    }

}



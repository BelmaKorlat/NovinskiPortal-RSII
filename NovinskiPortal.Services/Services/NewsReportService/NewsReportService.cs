using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Common.Enumerations;
using NovinskiPortal.Model.Requests.NewsReport;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.NewsReportService
{
    public class NewsReportService : BaseService<NewsReportResponse, NewsReportSearchObject, NewsReport>,
          INewsReportService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;

        public NewsReportService(
            NovinskiPortalDbContext context,
            IMapper mapper)
            : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<NewsReportResponse> CreateAsync(CreateNewsReportRequest request, int? userId)
        {
            if (!userId.HasValue && string.IsNullOrWhiteSpace(request.Email))
            {
                throw new ArgumentException("Either userId or email must be provided.");
            }

            var entity = new NewsReport
            {
                UserId = userId,
                Email = userId.HasValue ? null : request.Email?.Trim(),
                Text = request.Text.Trim(),
                Status = NewsReportStatus.Pending,
                CreatedAt = DateTime.UtcNow,
                ProcessedAt = null,
                ArticleId = null,
                AdminNote = null
            };

            _context.NewsReports.Add(entity);
            await _context.SaveChangesAsync(); 


            if (request.Files != null && request.Files.Count > 0)
            {
                var uploadsFolder = EnsureUploadsFolder(entity.Id);

                foreach (var file in request.Files)
                {
                    if (file.Content == null || file.Content.Length == 0)
                        continue;

                    var filePath = SaveReportFile(file, uploadsFolder, entity.Id);

                    var fileEntity = new NewsReportFile
                    {
                        NewsReportId = entity.Id,
                        OriginalFileName = file.FileName,
                        FilePath = filePath,      
                        ContentType = file.ContentType,
                        Size = file.Content.LongLength
                    };

                    _context.NewsReportFiles.Add(fileEntity);
                }

                await _context.SaveChangesAsync();
            }

            var loaded = await _context.NewsReports
                .Include(x => x.Files)
                .Include(x => x.User)
                .FirstAsync(x => x.Id == entity.Id);


            var response = MapToResponse(loaded);
            return response;
        }

        protected override IQueryable<NewsReport> ApplyFilter(IQueryable<NewsReport> query, NewsReportSearchObject search)
        {
            if (search.Status.HasValue)
            {
                query = query.Where(x => x.Status == search.Status.Value);
            }

            return query;
        }

        protected override IOrderedQueryable<NewsReport>? ApplyOrder(IQueryable<NewsReport> query,NewsReportSearchObject search)
        {
            return query.OrderByDescending(x => x.CreatedAt);
        }

        protected override IQueryable<NewsReport> ApplyIncludes(IQueryable<NewsReport> query)
        {
            return query
                .Include(x => x.Files)
                .Include(x => x.User);
        }

        public override async Task<NewsReportResponse?> GetByIdAsync(int id)
        {
            var entity = await ApplyIncludes(_context.NewsReports.AsQueryable())
               .AsNoTracking()
               .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
                return null;

            return entity is null ? null : MapToResponse(entity);
        }

        public async Task<NewsReportResponse?> UpdateStatusAsync(int id, UpdateNewsReportStatusRequest request)
        {
            var entity = await ApplyIncludes(_context.NewsReports.AsQueryable())
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
                return null;

            entity.Status = request.Status;
            entity.AdminNote = request.AdminNote;
            // entity.ArticleId = request.ArticleId;
            if (request.ArticleId.HasValue && request.ArticleId.Value > 0)
            {
                entity.ArticleId = request.ArticleId.Value;
            }
            else
            {
                entity.ArticleId = null;
            }
            entity.ProcessedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }


        private static string EnsureUploadsFolder(int reportId)
        {
            var root = Directory.GetCurrentDirectory();
            var uploadsFolder = Path.Combine(root, "wwwroot", "NewsReports", reportId.ToString());

            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);
            return uploadsFolder;
        }

        private static string SaveReportFile(NewsReportFileUpload file, string uploadsFolder, int reportId)
        {
            if (file.Content == null || file.Content.Length == 0)
                throw new ArgumentException("File is empty.");

            var allowed = new[] { ".jpg", ".jpeg", ".png", ".webp", ".pdf" };

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowed.Contains(extension))
                throw new InvalidOperationException("Unsupported file type.");

            var safeFileName = $"{Guid.NewGuid():N}{extension}";
            var physicalPath = Path.Combine(uploadsFolder, safeFileName);

            File.WriteAllBytes(physicalPath, file.Content);

            return $"/NewsReports/{reportId}/{safeFileName}";
        }

        public async Task<int> GetPendingCountAsync()
        {
            return await _context.NewsReports
                .Where(x => x.Status == NewsReportStatus.Pending)
                .CountAsync();
        }
    }
}

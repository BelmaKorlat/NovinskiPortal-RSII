using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Common.Enumerations;
using NovinskiPortal.Model.Requests.AdminComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.AdminCommentService
{
    public class AdminCommentService : BaseService<AdminCommentReportResponse, AdminCommentReportSearchObject, ArticleComment>, IAdminCommentService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;

        public AdminCommentService(NovinskiPortalDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        protected override IQueryable<ArticleComment> ApplyFilter(IQueryable<ArticleComment> query, AdminCommentReportSearchObject search)
        {
            query = query.Where(c => c.Reports.Any());

            if (search.Status.HasValue)
            {
                var status = search.Status.Value;
                query = query.Where(c => c.Reports.Any(r => r.Status == status));
            }

            return query;
        }

        protected override IQueryable<ArticleComment> ApplyIncludes(IQueryable<ArticleComment> query)
        {
            return query
                .Include(c => c.Article)
                .Include(c => c.User)
                .Include(c => c.Reports);
        }

        protected override IOrderedQueryable<ArticleComment>? ApplyOrder(IQueryable<ArticleComment> query, AdminCommentReportSearchObject search)
        {
            return query.OrderByDescending(c => c.Reports.Max(r => r.CreatedAt));
        }

        public async Task<AdminCommentDetailReportResponse?> GetDetailAsync(int commentId)
        {
            var query = ApplyIncludes(_context.ArticleComments.AsQueryable())
                       .Include(c => c.Reports).ThenInclude(r => r.ReporterUser)
                       .Include(c => c.Reports).ThenInclude(r => r.ProcessedByAdmin);

            var comment = await query.FirstOrDefaultAsync(c => c.Id == commentId);

            if (comment == null)
                return null;

            var detail = _mapper.Map<AdminCommentDetailReportResponse>(comment);
            return detail;
        }

        /*public async Task<bool> HideAsync(int id)
        {
            var comment = await _context.ArticleComments
            .FirstOrDefaultAsync(c => c.Id == id);

            if (comment is null)
                return false;

            if (comment.IsHidden)
                return true;

            comment.IsHidden = true;

            await _context.SaveChangesAsync();
            return true;
        }*/

        public async Task<bool> HideAsync(int id, int adminUserId)
        {
            var comment = await _context.ArticleComments
                .Include(c => c.Reports)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (comment is null)
                return false;

            var now = DateTime.UtcNow;
            var changed = false;

            if (!comment.IsHidden)
            {
                comment.IsHidden = true;
                changed = true;
            }

            if (comment.Reports != null && comment.Reports.Count > 0)
            {
                var pendingReports = comment.Reports
                    .Where(r => r.Status == ArticleCommentReportStatus.Pending)
                    .ToList();

                foreach (var report in pendingReports)
                {
                    report.Status = ArticleCommentReportStatus.Approved;
                    report.ProcessedAt = now;
                    report.ProcessedByAdminId = adminUserId;
                    // AdminNote možeš kasnije dodati kroz request ako želiš
                    changed = true;
                }
            }

            if (!changed)
                return true; 

            await _context.SaveChangesAsync();
            return true;
        }


        /*public async Task<bool> SoftDeleteAsync(int id)
        {
            var comment = await _context.ArticleComments
            .FirstOrDefaultAsync(c => c.Id == id);

            if (comment is null)
                return false;

            if (comment.IsDeleted)
                return true;

            comment.IsDeleted = true;
            comment.IsHidden = true;

            await _context.SaveChangesAsync();
            return true;
        }*/

        public async Task<bool> SoftDeleteAsync(int id, int adminUserId)
        {
            var comment = await _context.ArticleComments
                .Include(c => c.Reports)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (comment is null)
                return false;

            var now = DateTime.UtcNow;
            var changed = false;

            if (!comment.IsDeleted)
            {
                comment.IsDeleted = true;
                changed = true;
            }

            if (!comment.IsHidden)
            {
                comment.IsHidden = true;
                changed = true;
            }

            if (comment.Reports != null && comment.Reports.Count > 0)
            {
                var pendingReports = comment.Reports
                    .Where(r => r.Status == ArticleCommentReportStatus.Pending)
                    .ToList();

                foreach (var report in pendingReports)
                {
                    report.Status = ArticleCommentReportStatus.Approved;
                    report.ProcessedAt = now;
                    report.ProcessedByAdminId = adminUserId;
                    changed = true;
                }
            }

            if (!changed)
                return true;

            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<bool> RejectPendingReportsAsync(int commentId, int adminUserId, string? adminNote)
        {
            var comment = await _context.ArticleComments
                .Include(c => c.Reports)
                .FirstOrDefaultAsync(c => c.Id == commentId);

            if (comment is null)
                return false;

            if (comment.Reports == null || comment.Reports.Count == 0)
                return true; 

            var pendingReports = comment.Reports
                .Where(r => r.Status == ArticleCommentReportStatus.Pending)
                .ToList();

            if (pendingReports.Count == 0)
                return true; 

            var note = string.IsNullOrWhiteSpace(adminNote)
                ? null
                : adminNote.Trim();

            var now = DateTime.UtcNow;

            foreach (var report in pendingReports)
            {
                report.Status = ArticleCommentReportStatus.Rejected;
                report.ProcessedAt = now;
                report.ProcessedByAdminId = adminUserId;
                if (note != null)
                {
                    report.AdminNote = note;
                }
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BanAuthorAsync(int commentId, BanCommentAuthorRequest request)
        {
            var comment = await _context.ArticleComments
                .Include(c => c.User)
                .FirstOrDefaultAsync(c => c.Id == commentId);

            if (comment is null)
                return false;

            var user = comment.User;
            if (user == null || user.IsDeleted)
                return false; 

            if (request.BanUntil <= DateTime.UtcNow)
            {
                return false;
            }

            var utcBanUntil = request.BanUntil.Kind == DateTimeKind.Utc
                ? request.BanUntil
                : request.BanUntil.ToUniversalTime();

            user.CommentBanUntil = utcBanUntil;
            user.CommentBanReason = string.IsNullOrWhiteSpace(request.Reason)
                ? null
                : request.Reason.Trim();

            await _context.SaveChangesAsync();
            return true;
        }
    }
}


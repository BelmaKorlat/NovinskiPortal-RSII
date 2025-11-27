using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Common.Enumerations;
using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;

namespace NovinskiPortal.Services.Services.ArticleCommentReportService
{
    public class ArticleCommentReportService : IArticleCommentReportService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;

        public ArticleCommentReportService(NovinskiPortalDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<ArticleCommentResponse?> ReportAsync(ArticleCommentReportRequest request, int currentUserId)
        {
            if (string.IsNullOrWhiteSpace(request.Reason))
                return null;

            var comment = await _context.ArticleComments
                .FirstOrDefaultAsync(c =>
                    c.Id == request.CommentId &&
                    !c.IsDeleted &&
                    !c.IsHidden);

            if (comment == null)
                return null;

            if (comment.UserId == currentUserId)
                return null;

            var existing = await _context.ArticleCommentReports
                .FirstOrDefaultAsync(r =>
                    r.ArticleCommentId == request.CommentId &&
                    r.ReporterUserId == currentUserId);

            if (existing != null)
                return null;

            var report = new ArticleCommentReport
            {
                ArticleCommentId = request.CommentId,
                ReporterUserId = currentUserId,
                Reason = request.Reason.Trim(),
                CreatedAt = DateTime.UtcNow,
                Status = ArticleCommentReportStatus.Pending,
                ProcessedAt = null,
                ProcessedByAdminId = null,
                AdminNote = string.Empty
            };

            comment.ReportsCount++;

            _context.ArticleCommentReports.Add(report);
            await _context.SaveChangesAsync();

            await _context.Entry(comment)
                .Reference(c => c.User)
                .LoadAsync();

            var dto = _mapper.Map<ArticleCommentResponse>(comment);

            dto.IsOwner = comment.UserId == currentUserId;

            var vote = await _context.ArticleCommentVotes
                .FirstOrDefaultAsync(v =>
                    v.ArticleCommentId == comment.Id &&
                    v.UserId == currentUserId);

            dto.userVote = vote?.Value;

            return dto;
        }
    }
}

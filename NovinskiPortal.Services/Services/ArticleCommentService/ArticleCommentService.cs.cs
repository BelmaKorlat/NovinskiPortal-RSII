using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.Services.Services.ArticleCommentService
{
    public class ArticleCommentService : BaseService<ArticleCommentResponse, ArticleCommentSearchObject, ArticleComment>, IArticleCommentService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;

        public ArticleCommentService(NovinskiPortalDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        protected override IQueryable<ArticleComment> ApplyFilter(IQueryable<ArticleComment> query, ArticleCommentSearchObject search)
        {
            query = query.Where(c => c.ArticleId == search.ArticleId);

            query = query.Where(c => !c.IsDeleted && !c.IsHidden);

            return query;
        }

        protected override IOrderedQueryable<ArticleComment>? ApplyOrder(IQueryable<ArticleComment> query, ArticleCommentSearchObject search)
        {
            return query.OrderByDescending(c => c.CreatedAt);
        }

        protected override IQueryable<ArticleComment> ApplyIncludes(IQueryable<ArticleComment> query)
        {
            return query.Include(c => c.User);
        }

        public async Task<ArticleCommentResponse?> CreateAsync(int articleId, ArticleCommentCreateRequest request, int currentUserId)
        {
            var user = await _context.Users
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.Id == currentUserId && !u.IsDeleted && u.Active);

            if (user == null)
                return null;

            if (user.CommentBanUntil.HasValue && user.CommentBanUntil > DateTime.UtcNow)
                return null;

            var article = await _context.Articles
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.Id == articleId && a.Active);

            if (article == null)
                return null;

            var entity = new ArticleComment
            {
                ArticleId = articleId,
                UserId = currentUserId,
                ParentCommentId = null,
                Content = request.Content.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false,
                IsHidden = false,
                LikesCount = 0,
                DislikesCount = 0,
                ReportsCount = 0
            };

            _context.ArticleComments.Add(entity);
            await _context.SaveChangesAsync();

            await _context.Entry(entity)
                .Reference(c => c.User)
                .LoadAsync();

            var dto = _mapper.Map<ArticleCommentResponse>(entity);

            dto.IsOwner = true;        
            dto.userVote = null;       

            return dto;
        }

        public async Task<PagedResult<ArticleCommentResponse>> GetArticleCommentAsync(ArticleCommentSearchObject search, int? currentUserId)
        {
            var result = await base.GetAsync(search);

            if (currentUserId == null || currentUserId <= 0)
                return result;

            var userId = currentUserId.Value;

            var commentIds = result.Items.Select(c => c.Id).ToList();
            if (commentIds.Count == 0)
                return result;

            var votes = await _context.ArticleCommentVotes
                .Where(v => v.UserId == userId && commentIds.Contains(v.ArticleCommentId))
                .ToListAsync();

            var votesByCommentId = votes.ToDictionary(v => v.ArticleCommentId, v => v.Value);

            foreach (var dto in result.Items)
            {
                dto.IsOwner = dto.UserId == userId;

                if (votesByCommentId.TryGetValue(dto.Id, out var value))
                    dto.userVote = value;   // 1 ili -1
                else
                    dto.userVote = null;
            }

            return result;
        }
    }
}

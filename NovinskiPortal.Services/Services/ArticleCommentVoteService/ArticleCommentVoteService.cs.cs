using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Database;
using NovinskiPortal.Services.Database.Entities;

namespace NovinskiPortal.Services.Services.ArticleCommentVoteService
{
    public class ArticleCommentVoteService : IArticleCommentVoteService
    {
        private readonly NovinskiPortalDbContext _context;
        private readonly IMapper _mapper;

        public ArticleCommentVoteService(NovinskiPortalDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<ArticleCommentResponse?> VoteAsync(ArticleCommentVoteRequest request, int currentUserId)
        {
            if (request.Value != 1 && request.Value != -1)
                return null;

            var comment = await _context.ArticleComments
                .FirstOrDefaultAsync(c => c.Id == request.CommentId && !c.IsDeleted && !c.IsHidden);

            if (comment == null)
                return null;

            var vote = await _context.ArticleCommentVotes
                .FirstOrDefaultAsync(v =>
                    v.ArticleCommentId == request.CommentId &&
                    v.UserId == currentUserId);

            int? newUserVote;

            if (vote == null)
            {
                vote = new ArticleCommentVote
                {
                    ArticleCommentId = request.CommentId,
                    UserId = currentUserId,
                    Value = request.Value,
                    CreatedAt = DateTime.UtcNow
                };

                _context.ArticleCommentVotes.Add(vote);

                if (request.Value == 1)
                    comment.LikesCount++;
                else
                    comment.DislikesCount++;

                newUserVote = request.Value;
            }
            else if (vote.Value == request.Value)
            {
                if (vote.Value == 1)
                    comment.LikesCount--;
                else
                    comment.DislikesCount--;

                _context.ArticleCommentVotes.Remove(vote);
                newUserVote = null;
            }
            else
            {
                if (vote.Value == 1)
                {
                    comment.LikesCount--;
                    comment.DislikesCount++;
                }
                else
                {
                    comment.DislikesCount--;
                    comment.LikesCount++;
                }

                vote.Value = request.Value;
                newUserVote = request.Value;
            }

            await _context.SaveChangesAsync();

            await _context.Entry(comment)
                .Reference(c => c.User)
                .LoadAsync();

            var dto = _mapper.Map<ArticleCommentResponse>(comment);

            dto.IsOwner = comment.UserId == currentUserId;
            dto.userVote = newUserVote;

            return dto;
        }

    }
}

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
            // 1) validacija vrijednosti
            if (request.Value != 1 && request.Value != -1)
                return null;

            // 2) nadji komentar
            var comment = await _context.ArticleComments
                .FirstOrDefaultAsync(c => c.Id == request.CommentId && !c.IsDeleted && !c.IsHidden);

            if (comment == null)
                return null;

            // 3) nadji postojeci glas korisnika za ovaj komentar
            var vote = await _context.ArticleCommentVotes
                .FirstOrDefaultAsync(v =>
                    v.ArticleCommentId == request.CommentId &&
                    v.UserId == currentUserId);

            int? newUserVote;

            if (vote == null)
            {
                // korisnik prvi put glasa
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
                // korisnik kliknuo isto dugme drugi put - uklanja se glas
                if (vote.Value == 1)
                    comment.LikesCount--;
                else
                    comment.DislikesCount--;

                _context.ArticleCommentVotes.Remove(vote);
                newUserVote = null;
            }
            else
            {
                // korisnik mijenja glas sa like na dislike ili obrnuto
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

            // 4) ucitaj User radi Username u DTO-u
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

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.ArticleComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.ArticleCommentReportService;
using NovinskiPortal.Services.Services.ArticleCommentService;
using NovinskiPortal.Services.Services.ArticleCommentVoteService;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ArticleCommentsController : ControllerBase
    {
        private readonly IArticleCommentService _articleCommentService;
        private readonly IArticleCommentVoteService _articleCommentVoteService;
        private readonly IArticleCommentReportService _articleCommentReportService;


        public ArticleCommentsController(IArticleCommentService articleCommentService, 
            IArticleCommentVoteService articleCommentVoteService, 
            IArticleCommentReportService articleCommentReportService)
        {
            _articleCommentService = articleCommentService;
            _articleCommentVoteService = articleCommentVoteService;
            _articleCommentReportService = articleCommentReportService;
        }
        private int? GetUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim == null)
                return null;

            if (!int.TryParse(claim.Value, out var id))
                return null;

            return id;
        }


        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<PagedResult<ArticleCommentResponse>>> GetAsync([FromQuery] ArticleCommentReportSearchObject search)
        {
            var currentUserId = GetUserId();

            var result = await _articleCommentService.GetArticleCommentAsync(
                search,
                currentUserId
            );

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<ArticleCommentResponse>> CreateAsync([FromQuery] int articleId, [FromBody] ArticleCommentCreateRequest request)
        {
            var currentUserId = GetUserId();
            if (currentUserId == null)
                return Unauthorized();

            var result = await _articleCommentService.CreateAsync(
                articleId,
                request,
                currentUserId.Value
            );

            if (result == null)
            {
                return BadRequest();
            }

            return Ok(result);
        }

        [HttpPost("vote")]
        public async Task<ActionResult<ArticleCommentResponse>> VoteAsync([FromBody] ArticleCommentVoteRequest request)
        {
            var currentUserId = GetUserId();
            if (currentUserId == null)
                return Unauthorized();

            var result = await _articleCommentVoteService.VoteAsync(
                request,
                currentUserId.Value
            );

            if (result == null)
                return BadRequest();

            return Ok(result);
        }

        [HttpPost("report")]
        public async Task<ActionResult<ArticleCommentResponse>> Report([FromBody] ArticleCommentReportRequest request)
        {
            var currentUserId = GetUserId();
            if (currentUserId == null)
                return Unauthorized();

             var result = await _articleCommentReportService.ReportAsync(
                 request,
                 currentUserId.Value
             );

             if (result == null)
                 return BadRequest();

             return Ok(result);

           
        }

    }
}

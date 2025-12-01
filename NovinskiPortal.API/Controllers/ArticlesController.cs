using Azure.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.API.Utils;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.ArticleReadService;
using NovinskiPortal.Services.Services.ArticleService;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ArticlesController : ControllerBase //BaseCRUDController<ArticleResponse, ArticleSearchObject, Model.Requests.Article.CreateArticleRequest, Model.Requests.Article.UpdateArticleRequest>
    {
        private readonly IArticleService _articleService;
        private readonly IArticleReadService _articleReadService;

        public ArticlesController(IArticleService articleService, IArticleReadService articleReadService)// : //base(articleService)
        {
            _articleService = articleService;
            _articleReadService = articleReadService;
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

        [HttpGet("category-articles")]
       public async Task<ActionResult<List<CategoryArticlesResponse>>> GetCategoryArticles([FromQuery] int perCategory = 5)
       {
            var items = await _articleService.GetCategoryArticlesAsync(perCategory);

            return Ok(items);
       }
        [HttpGet()]
        public async Task<ActionResult<PagedResult<ArticleResponse>>> GetAsync([FromQuery] ArticleSearchObject articleSearchObject)
        {
            if (articleSearchObject == null)
                articleSearchObject = new ArticleSearchObject();
            var result = await _articleService.GetAsync(articleSearchObject);
           /* if(result?.Items != null)
            {
                foreach (var item in result.Items)
                {
                    if (!string.IsNullOrEmpty(item.MainPhotoPath))
                    {
                        item.MainPhotoPath = ToAbsolute(item.MainPhotoPath);
                    }
                }
            }*/
            return Ok(result);
       }



        [HttpPost]
        //[Consumes("multipart/form-data")]
       public async Task<IActionResult> CreateArticleAsync([FromForm] Requests.Article.CreateArticleRequest createArticleRequest)
        {
            var userId = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userId == null)
                return Unauthorized();
            var publishedLocal = DateTime.SpecifyKind(createArticleRequest.PublishedAt, DateTimeKind.Local);

            var newArticle = new Model.Requests.Article.CreateArticleRequest
            {
                Headline = createArticleRequest.Headline,
                Subheadline = createArticleRequest.Subheadline,
                ShortText = createArticleRequest.ShortText,
                Text = createArticleRequest.Text,
                PublishedAt = publishedLocal.ToUniversalTime(),
                Active = createArticleRequest.Active,
                HideFullName = createArticleRequest.HideFullName,
                BreakingNews = createArticleRequest.BreakingNews,
                Live = createArticleRequest.Live,
                CategoryId = createArticleRequest.CategoryId,
                SubcategoryId = createArticleRequest.SubcategoryId,
                UserId = int.Parse(userId),
                MainPhoto = await FileHelpers.ToPhotoUploadAsync(createArticleRequest.MainPhoto),
                AdditionalPhotos = await FileHelpers.ToPhotoUploadsAsync(createArticleRequest.AdditionalPhotos)
            };

            var created = await _articleService.CreateAsync(newArticle);

            return Ok(created);
            //return CreatedAtAction(nameof(GetDetailById), new { id = created.Id }, created);
       }

        [HttpGet("{id}")]
        public async Task<ActionResult<ArticleResponse>> GetById(int id)
        {
            var item = await _articleService.GetByIdAsync(id);
            if (item is null)
                return NotFound();
            // item.MainPhotoPath = ToAbsolute(item.MainPhotoPath);
            return Ok(item);
        }

        [HttpGet("{id}/detail")]
        public async Task<ActionResult<ArticleDetailResponse>> GetDetailById(int id)
        {
            var item = await _articleService.GetDetailByIdAsync(id);
            if( item is null )
                return NotFound();
            /*item.MainPhotoPath = ToAbsolute(item.MainPhotoPath);
            if (item.AdditionalPhotos != null && item.AdditionalPhotos.Count > 0)
                item.AdditionalPhotos = item.AdditionalPhotos.Select(ToAbsolute).ToList();*/
            return Ok(item);
        }

        /*private string ToAbsolute(string? path)
        {
            if (string.IsNullOrWhiteSpace(path)) return "";
            var request = HttpContext.Request;
            return $"{request.Scheme}://{request.Host}{request.PathBase}{path}";
        }*/


        [HttpPut("{id}")]
        public async Task<ActionResult<ArticleResponse>> UpdateArticleAsync(int id, [FromForm] Requests.Article.UpdateArticleRequest updateArticleRequest)
        {
            var userId = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userId == null)
                return Unauthorized();

            var updatedArticle = new Model.Requests.Article.UpdateArticleRequest
            {
                Headline = updateArticleRequest.Headline,
                Subheadline = updateArticleRequest.Subheadline,
                ShortText = updateArticleRequest.ShortText,
                Text = updateArticleRequest.Text,
                PublishedAt = updateArticleRequest.PublishedAt,
                Active = updateArticleRequest.Active,
                HideFullName = updateArticleRequest.HideFullName,
                BreakingNews = updateArticleRequest.BreakingNews,
                Live = updateArticleRequest.Live,
                CategoryId = updateArticleRequest.CategoryId,
                SubcategoryId = updateArticleRequest.SubcategoryId,
                UserId = int.Parse(userId),
                MainPhoto = updateArticleRequest.MainPhoto != null
                ? await FileHelpers.ToPhotoUploadAsync(updateArticleRequest.MainPhoto)
                : null,
                AdditionalPhotos = updateArticleRequest.AdditionalPhotos != null && updateArticleRequest.AdditionalPhotos.Count > 0
                ? await FileHelpers.ToPhotoUploadsAsync(updateArticleRequest.AdditionalPhotos)
                : null
            };

            var updated = await _articleService.UpdateAsync(id, updatedArticle);
            return Ok(updated);
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> ToggleStatusAsync(int id)
        {
            var articleDto = await _articleService.ToggleArticleStatusAsync(id);
            return articleDto is null ? NotFound() : Ok(articleDto);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            var deleted = await _articleService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }

        [HttpPost("{id}/track-view")]
        [AllowAnonymous]
        public async Task<IActionResult> TrackViewAsync(int id)
        {
            var userId = GetUserId();

            await _articleReadService.TrackViewAsync(id, userId);

            return Accepted();
        }
    }
}

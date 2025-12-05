using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Services.Services.FavoriteService;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] 
    public class FavoritesController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;

        public FavoritesController(IFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
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
        public async Task<IActionResult> Get()
        {
            var userId = GetUserId();
            if (userId == null)
                return Unauthorized();

            var items = await _favoriteService.GetAsync(userId.Value);
            return Ok(items);
        }

        [HttpPost("{articleId}")]
        public async Task<IActionResult> Add(int articleId)
        {
            var userId = GetUserId();
            if (userId == null)
                return Unauthorized();

            var ok = await _favoriteService.AddAsync(userId.Value, articleId);
            if (!ok)
                return BadRequest();

            return Ok(); 
        }


        [HttpDelete("{articleId}")]
        public async Task<IActionResult> Remove(int articleId)
        {
            var userId = GetUserId();
            if (userId == null)
                return Unauthorized();
            var ok = await _favoriteService.RemoveAsync(userId.Value, articleId);
            if (!ok)
                return NotFound(); 

            return NoContent();
        }


        [HttpGet("{articleId}/is-favorite")]
        public async Task<IActionResult> IsFavorite(int articleId)
        {
            var userId = GetUserId();
            if (userId == null)
                return Unauthorized();

            var isFav = await _favoriteService.IsFavoriteAsync(userId.Value, articleId);
            return Ok(isFav);
        }
    }
}

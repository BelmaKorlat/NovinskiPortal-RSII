using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Services.RecommendationService;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class RecommendationController : ControllerBase
    {
        private int? GetUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim == null)
                return null;

            if (!int.TryParse(claim.Value, out var id))
                return null;

            return id;
        }

        [HttpGet("personalized")]
        public async Task<ActionResult<List<ArticleResponse>>> GetPersonalizedAsync([FromServices] IRecommendationService recommendationService, [FromQuery] int take = 10)
        {
            var userId = GetUserId();
            if (userId == null)
                return Unauthorized();

            var result = await recommendationService.GetPersonalizedAsync(userId.Value, take);

            return Ok(result);
        }
    }
}

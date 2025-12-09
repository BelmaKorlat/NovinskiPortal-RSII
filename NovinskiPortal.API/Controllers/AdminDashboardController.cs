using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Reporting.NETCore;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Services.Services.AdminDashboardService;
using System.Data;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminDashboardController : ControllerBase
    {
        private readonly IAdminDashboardService _service;

        public AdminDashboardController(IAdminDashboardService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<AdminDashboardSummaryResponse>> GetSummary()
        {
            var result = await _service.GetSummaryAsync();
            return Ok(result);
        }

        [HttpGet("top-articles")]
        public async Task<ActionResult<List<TopArticleDashboardResponse>>> GetTopArticles([FromQuery] int? categoryId, [FromQuery] DateTime? from, [FromQuery] DateTime? to, [FromQuery] int take = 15)
        {
            var items = await _service.GetTopArticlesAsync(categoryId, from, to, take);
            return Ok(items);
        }

        [HttpGet("top-articles-report")]
           public async Task<IActionResult> GetTopArticlesReport([FromQuery] int? categoryId, [FromQuery] DateTime? from, [FromQuery] DateTime? to, [FromQuery] int take = 15)
           {
               var bytes = await _service.GenerateTopArticlesPdfAsync(categoryId, from, to, take);

               var fileName = $"top-articles-{DateTime.UtcNow:yyyyMMddHHmm}.pdf";

               return File(bytes, "application/pdf", fileName);
           }

           [HttpGet("category-views-report")]
           public async Task<IActionResult> GetCategoryViewsReport()
           {
               var bytes = await _service.GenerateCategoryViewsLast30DaysPdfAsync();

               var fileName = $"category-views-last30days-{DateTime.UtcNow:yyyyMMddHHmm}.pdf";

               return File(bytes, "application/pdf", fileName);
           }

    }
}

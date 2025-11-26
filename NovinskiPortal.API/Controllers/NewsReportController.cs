using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.API.Utils;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;
using NovinskiPortal.Services.Services.NewsReportService;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NewsReportController : ControllerBase
    {
        private readonly INewsReportService _newsReportService;

        public NewsReportController(INewsReportService newsReportService)
        {
            _newsReportService = newsReportService;
        }

        // 1) Kreiranje dojave (korisnik, može biti guest)
        [HttpPost]
        [AllowAnonymous]
        public async Task<ActionResult<NewsReportResponse>> Create([FromForm] Requests.NewsReport.CreateNewsReportRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            int? userId = null;

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out var parsedUserId))
                userId = parsedUserId;

            var files = new List<Model.Requests.NewsReport.NewsReportFileUpload>();

            var serviceRequest = new Model.Requests.NewsReport.CreateNewsReportRequest
            {
                Email = request.Email,
                Text = request.Text,
                Files = await FileHelpers.ToNewsReportFileUploadsAsync(request.Files)
            };

            var created = await _newsReportService.CreateAsync(serviceRequest, userId);

            return Ok(created);
        }

        // 2) Lista dojava (admin dio)
        [HttpGet]
        public async Task<ActionResult<PagedResult<NewsReportResponse>>> Get([FromQuery] NewsReportSearchObject? search)
        {
            if(search == null)
                search = new NewsReportSearchObject();

            var result = await _newsReportService.GetAsync(search);

            return Ok(result);
        }

        // 3) Detalji dojave po Id (admin dio)
        [HttpGet("{id}")]
        public async Task<ActionResult<NewsReportResponse>> GetById(int id)
        {
            var item = await _newsReportService.GetByIdAsync(id);

            if (item is null)
                return NotFound();

            return Ok(item);
        }

        [HttpPut("{id}/status")]
        public async Task<ActionResult<NewsReportResponse>> UpdateStatus( int id, [FromBody] Model.Requests.NewsReport.UpdateNewsReportStatusRequest request)
        {
            var updated = await _newsReportService.UpdateStatusAsync(id, request);

            if (updated is null)
                return NotFound();

            return Ok(updated);
        }

        [HttpGet("pending-count")]
        public async Task<ActionResult<int>> GetPendingCount()
        {
            var count = await _newsReportService.GetPendingCountAsync();
            return Ok(count);
        }
    }
}

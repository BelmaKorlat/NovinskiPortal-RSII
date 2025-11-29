using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Requests.AdminComment;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.AdminCommentService;
using System.Security.Claims;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AdminCommentsController : ControllerBase
    {
        private readonly IAdminCommentService _adminCommentService;

        public AdminCommentsController(IAdminCommentService adminCommentService)
        {
            _adminCommentService = adminCommentService;
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


        [HttpGet()]
        public async Task<ActionResult<PagedResult<AdminCommentReportResponse>>> GetReported([FromQuery] AdminCommentReportSearchObject search)
        {
            var result = await _adminCommentService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("{id}/detail")]
        public async Task<ActionResult<AdminCommentDetailReportResponse>> GetDetail(int id)
        {
            var result = await _adminCommentService.GetDetailAsync(id);
            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost("{id}/hide")]
        public async Task<IActionResult> Hide(int id)
        {
            var adminId = GetUserId();
            if (adminId == null)
                return Unauthorized();

            var ok = await _adminCommentService.HideAsync(id, adminId.Value);
            if (!ok)
                return NotFound();

            return NoContent();
        }

        [HttpDelete("{id}/soft-delete")]
        public async Task<IActionResult> SoftDelete(int id)
        {
            var adminId = GetUserId();
            if (adminId == null)
                return Unauthorized();

            var ok = await _adminCommentService.SoftDeleteAsync(id, adminId.Value);
            if (!ok)
                return NotFound();

            return NoContent();
        }

        [HttpPost("{id}/reports/reject-pending")]
        public async Task<IActionResult> RejectPendingReports(int id, [FromBody] RejectCommentReportsRequest request)
        {
            var adminId = GetUserId();
            if (adminId == null)
                return Unauthorized();

            var ok = await _adminCommentService.RejectPendingReportsAsync(id, adminId.Value, request.AdminNote);

            if (!ok)
                return NotFound();

            return NoContent();
        }

        [HttpPost("{id:int}/ban-author")]
        public async Task<IActionResult> BanAuthor(int id, [FromBody] BanCommentAuthorRequest request)
        {
            var adminId = GetUserId();
            if (adminId == null)
                return Unauthorized();

            var ok = await _adminCommentService.BanAuthorAsync(id, request);
            if (!ok)
                return NotFound(); 

            return NoContent();
        }

    }
}

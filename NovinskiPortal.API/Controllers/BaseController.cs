using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NovinskiPortal.Model.Responses;
using NovinskiPortal.Model.SearchObjects;
using NovinskiPortal.Services.Services.BaseService;

namespace NovinskiPortal.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BaseController<T, TSearch> : ControllerBase
                where T : class
                where TSearch : BaseSearchObject, new()
    {
        protected readonly IService<T, TSearch> _service;
        public BaseController(IService<T, TSearch> service)
        {
            _service = service;
        }

        [HttpGet("")]
        public async Task<PagedResult<T>> GetAsync([FromQuery] TSearch? searchTerm = null)
        {
            return await _service.GetAsync(searchTerm ?? new TSearch());
        }
        [HttpGet("{id}")]
        public async Task<T?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}

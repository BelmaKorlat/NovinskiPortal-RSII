

using NovinskiPortal.Services.Database.Entities;

namespace NovinskiPortal.Services.Services.JwtService
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}

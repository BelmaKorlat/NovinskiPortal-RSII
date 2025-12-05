

namespace NovinskiPortal.Commom.PasswordService
{
    public interface IPasswordService
    {
        string GenerateSalt();

        string HashPassword(string password, string salt);

        bool VerifyPassword(string password, string storedSalt, string storedHash);
    }
}

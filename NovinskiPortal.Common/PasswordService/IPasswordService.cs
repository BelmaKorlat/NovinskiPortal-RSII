

namespace NovinskiPortal.Commom.PasswordService
{
    public interface IPasswordService
    {
        /// <summary>
        /// Generira nasumični salt u Base64 formatu.
        /// </summary>
        string GenerateSalt();

        /// <summary>
        /// Izračunava PBKDF2 hash na temelju passworda i salta. 
        /// Vraća Base64 string.
        /// </summary>
        string HashPassword(string password, string salt);

        /// <summary>
        /// Provjerava password uspoređujući hash i salt.
        /// </summary>
        bool VerifyPassword(string password, string storedSalt, string storedHash);
    }
}

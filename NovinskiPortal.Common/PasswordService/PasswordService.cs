

using System.Security.Cryptography;

namespace NovinskiPortal.Commom.PasswordService
{
    public class PasswordService : IPasswordService
    {
        private const int SaltSize = 16;        
        private const int KeySize = 32;         
        private const int Iterations = 100_000; 
    
        public string GenerateSalt()
        {
            var saltBytes = RandomNumberGenerator.GetBytes(SaltSize);
            return Convert.ToBase64String(saltBytes);
        }

        public string HashPassword(string password, string salt)
        {
            var saltBytes = Convert.FromBase64String(salt);

            using var pbkdf2 = new Rfc2898DeriveBytes(
                password: password,
                salt: saltBytes,
                iterations: Iterations,
                hashAlgorithm: HashAlgorithmName.SHA256);

            var keyBytes = pbkdf2.GetBytes(KeySize);
            return Convert.ToBase64String(keyBytes);
        }

        public bool VerifyPassword(string password, string storedSalt, string storedHash)
        {
            var computed = HashPassword(password, storedSalt);

            var a = Convert.FromBase64String(computed);
            var b = Convert.FromBase64String(storedHash);
            return CryptographicOperations.FixedTimeEquals(a, b);
        }
    }
}

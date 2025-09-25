

using System.Security.Cryptography;

namespace NovinskiPortal.Commom.PasswordService
{
    public class PasswordService : IPasswordService
    {
        private const int SaltSize = 16;        // 16 bajtova = 128 bit
        private const int KeySize = 32;         // 32 bajta = 256 bit
        private const int Iterations = 100_000; // PBKDF2 iteracije

        /// <summary>
        /// Generira nasumični salt i vraća ga kao Base64 string.
        /// </summary>
        public string GenerateSalt()
        {
            // Generišemo 16 random bajtova
            var saltBytes = RandomNumberGenerator.GetBytes(SaltSize);
            return Convert.ToBase64String(saltBytes);
        }

        /// <summary>
        /// Izračunava PBKDF2 hash od passworda i zadanog salta. 
        /// Vraća Base64 string.
        /// </summary>
        public string HashPassword(string password, string salt)
        {
            // Salt primljen kao Base64 dekodiramo natrag u bajtove
            var saltBytes = Convert.FromBase64String(salt);

            using var pbkdf2 = new Rfc2898DeriveBytes(
                password: password,
                salt: saltBytes,
                iterations: Iterations,
                hashAlgorithm: HashAlgorithmName.SHA256);

            var keyBytes = pbkdf2.GetBytes(KeySize);
            return Convert.ToBase64String(keyBytes);
        }

        /// <summary>
        /// Provjerava da li je upisana lozinka ispravna uspoređujući
        /// ponovno izračunati hash s onim spremljenim.
        /// </summary>
        public bool VerifyPassword(string password, string storedSalt, string storedHash)
        {
            // Izračunamo hash upisane lozinke
            var computed = HashPassword(password, storedSalt);

            // Konstantno-vremenska usporedba
            var a = Convert.FromBase64String(computed);
            var b = Convert.FromBase64String(storedHash);
            return CryptographicOperations.FixedTimeEquals(a, b);
        }
    }
}

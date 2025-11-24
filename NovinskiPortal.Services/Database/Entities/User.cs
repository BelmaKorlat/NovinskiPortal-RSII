namespace NovinskiPortal.Services.Database.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Nick { get; set; } = default!;
        public string Username { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string PasswordHash { get; set; } = default!;
        public string PasswordSalt { get; set; } = default!;
        public Role Role { get; set; } = null!;
        public int RoleId { get; set; }
        public bool Active { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? LastLoginAt { get; set; }
        public bool IsDeleted { get; set; } = false;
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    }
}

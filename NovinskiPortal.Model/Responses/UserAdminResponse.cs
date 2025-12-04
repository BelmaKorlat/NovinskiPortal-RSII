

namespace NovinskiPortal.Model.Responses
{
    public class UserAdminResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Nick { get; set; } = default!;
        public string Username { get; set; } = default!;
        public string Email { get; set; } = default!;
        public int RoleId { get; set; }
        public string RoleName { get; set; } = default!;
        public bool Active { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public DateTime? CommentBanUntil { get; set; }
        public string? CommentBanReason { get; set; }
    }
}

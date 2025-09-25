

namespace NovinskiPortal.Model.Responses
{
    public class ProfileResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Nick { get; set; } = default!;
        public string Username { get; set; } = default!;
        public string Email { get; set; } = default!;
        public int RoleId { get; set; }
        public bool Active { get; set; }
    }
}

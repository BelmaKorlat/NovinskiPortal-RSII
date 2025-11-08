

namespace NovinskiPortal.Model.Responses
{
    public class UserResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Username { get; set; } = default!;
        public int RoleId { get; set; }
        public string RoleName { get; set; } = default!;
    }
}

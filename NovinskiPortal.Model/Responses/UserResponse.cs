

namespace NovinskiPortal.Model.Responses
{
    public class UserResponse
    {
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Username { get; set; } = default!;
        public int Role { get; set; }
    }
}



namespace NovinskiPortal.Services.Database.Entities
{
    public class Role
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;  
        public bool Active { get; set; } = true;
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}

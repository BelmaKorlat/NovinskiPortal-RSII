namespace NovinskiPortal.Services.Database.Entities
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public int OrdinalNumber { get; set; }
        public string Color { get; set; } = default!;
        public bool Active { get; set; }
        public virtual ICollection<Article> Articles { get; set; } = default!;
    }
}

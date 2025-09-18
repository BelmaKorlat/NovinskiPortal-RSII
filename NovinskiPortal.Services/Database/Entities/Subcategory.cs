namespace NovinskiPortal.Services.Database.Entities
        {
    public class Subcategory
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public int OrdinalNumber { get; set; }
        public bool Active { get; set; }
        public int CategoryId { get; set; }
        public virtual Category Category { get; set; } = default!;
        public virtual ICollection<Article> Articles { get; set; } = default!;
    }
}

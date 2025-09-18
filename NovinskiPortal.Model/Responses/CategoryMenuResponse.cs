

namespace NovinskiPortal.Model.Responses
{
    public class CategoryMenuResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string Color { get; set; } = default!;
        public List<SubcategoryMenuResponse> Subcategories { get; set; } = new();
    }
}

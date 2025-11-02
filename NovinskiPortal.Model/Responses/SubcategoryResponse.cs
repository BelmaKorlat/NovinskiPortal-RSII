

namespace NovinskiPortal.Model.Responses
{
    public class SubcategoryResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public int OrdinalNumber { get; set; }
        public bool Active { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = default!;
    }
}

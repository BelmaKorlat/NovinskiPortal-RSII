namespace NovinskiPortal.Model.Responses
{
    public class CategoryViewsDashboardResponse
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = default!;
        public int TotalViews { get; set; }
    }
}

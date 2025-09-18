using System.ComponentModel.DataAnnotations;

namespace NovinskiPortal.Model.Requests.Category
{
    public class CreateCategoryRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Category name is required.")]
        [MinLength(1, ErrorMessage = "Category name min lenght is 1.")]
        [MaxLength(50, ErrorMessage = "Category name max lenght is 50.")]
        public string Name { get; set; } = default!;

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ordinal number is required.")]
        public int OrdinalNumber { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Color is required.")]
        public string Color { get; set; } = default!;
        public bool Active { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;


namespace NovinskiPortal.Model.Requests.Subcategory
{
    public class UpdateSubcategoryRequest
    {
        public int Id { get; set; } = default!;

        [Required(AllowEmptyStrings = false, ErrorMessage = "Subcategory name is required.")]
        [MinLength(1, ErrorMessage = "Subcategory name min lenght is 1.")]
        [MaxLength(50, ErrorMessage = "Subcategory name max lenght is 50.")]
        public string Name { get; set; } = default!;

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ordinal number is required.")]
        public int OrdinalNumber { get; set; }

        public bool Active { get; set; }
        public int CategoryId { get; set; }
    }
}

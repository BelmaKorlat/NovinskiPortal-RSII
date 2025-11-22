class SubcategoryMenuDto {
  final int id;
  final String name;

  SubcategoryMenuDto({required this.id, required this.name});

  factory SubcategoryMenuDto.fromJson(Map<String, dynamic> json) {
    return SubcategoryMenuDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class CategoryMenuDto {
  final int id;
  final String name;
  final String color;
  final List<SubcategoryMenuDto> subcategories;

  bool isExpanded;

  CategoryMenuDto({
    required this.id,
    required this.name,
    required this.color,
    required this.subcategories,
    this.isExpanded = false,
  });

  factory CategoryMenuDto.fromJson(Map<String, dynamic> json) {
    final subsJson = json['subcategories'] as List<dynamic>? ?? [];
    return CategoryMenuDto(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      subcategories: subsJson
          .map((e) => SubcategoryMenuDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

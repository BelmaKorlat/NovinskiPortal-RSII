// lib/models/category_models.dart
import '../core/base_search.dart';

class CategoryDto {
  final int id;
  final String name;
  final int ordinalNumber;
  final String color; // npr "#00AA66"
  final bool active;

  CategoryDto({
    required this.id,
    required this.name,
    required this.ordinalNumber,
    required this.color,
    required this.active,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> j) => CategoryDto(
    id: j['id'] as int,
    name: j['name'] as String,
    ordinalNumber: j['ordinalNumber'] as int,
    color: j['color'] as String,
    active: j['active'] as bool,
  );
}

// druga paginacija:
class CategorySearch extends BaseSearch {
  final bool? active;

  const CategorySearch({
    this.active,
    super.fts,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    if (active != null) q['Active'] = active.toString();
    return q;
  }
}

class CreateCategoryRequest {
  final String name;
  final int ordinalNumber;
  final String color; // u backendu je string
  final bool active;

  CreateCategoryRequest({
    required this.name,
    required this.ordinalNumber,
    required this.color,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ordinalNumber': ordinalNumber,
    'color': color,
    'active': active,
  };
}

class UpdateCategoryRequest {
  final String name;
  final int ordinalNumber;
  final String color;
  final bool active;

  UpdateCategoryRequest({
    required this.name,
    required this.ordinalNumber,
    required this.color,
    required this.active,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ordinalNumber': ordinalNumber,
    'color': color,
    'active': active,
  };
}

import '../core/base_search.dart';

class SubcategoryDto {
  final int id;
  final String name;
  final int ordinalNumber;
  final bool active;
  final int categoryId;
  final String? categoryName;

  SubcategoryDto({
    required this.id,
    required this.name,
    required this.ordinalNumber,
    required this.active,
    required this.categoryId,
    required this.categoryName,
  });

  factory SubcategoryDto.fromJson(Map<String, dynamic> j) => SubcategoryDto(
    id: j['id'] as int,
    name: j['name'] as String,
    ordinalNumber: j['ordinalNumber'] as int,
    active: j['active'] as bool,
    categoryId: j['categoryId'] as int,
    categoryName: j['categoryName'] as String?,
  );
}

class SubcategorySearch extends BaseSearch {
  final int? categoryId;
  final bool? active;

  const SubcategorySearch({
    this.categoryId,
    this.active,
    super.page = 0,
    super.pageSize = 10,
    super.includeTotalCount = true,
    super.retrieveAll = false,
  });

  @override
  Map<String, dynamic> toQuery() {
    final q = super.toQuery();
    if (active != null) q['Active'] = active.toString();
    if (categoryId != null) q['categoryId'] = categoryId;
    return q;
  }
}

class CreateSubcategoryRequest {
  final String name;
  final int ordinalNumber;
  final bool active;
  final int categoryId;

  CreateSubcategoryRequest({
    required this.name,
    required this.ordinalNumber,
    required this.active,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ordinalNumber': ordinalNumber,
    'active': active,
    'categoryId': categoryId,
  };
}

class UpdateSubcategoryRequest {
  final String name;
  final int ordinalNumber;
  final bool active;
  final int categoryId;

  UpdateSubcategoryRequest({
    required this.name,
    required this.ordinalNumber,
    required this.active,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'ordinalNumber': ordinalNumber,
    'active': active,
    'categoryId': categoryId,
  };
}

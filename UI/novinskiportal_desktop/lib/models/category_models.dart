// lib/models/category_models.dart
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

class PagedResult<T> {
  final List<T> items;
  final int? totalCount;
  PagedResult({required this.items, this.totalCount});
}

// druga paginacija:
class CategorySearch {
  final bool? active;
  final String? fts;

  // paging
  final int page; // 0-based
  final int pageSize;
  final bool includeTotalCount;

  // opcionalno: kad je true, server ignoriše paging i vraća sve
  final bool retrieveAll;

  CategorySearch({
    this.active,
    this.fts,
    this.page = 0,
    this.pageSize = 10,
    this.includeTotalCount = true,
    this.retrieveAll = false, // default: koristimo paginaciju
  });

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{};

    if (retrieveAll) {
      // tražimo sve: backend neće paginirati
      q['RetrieveAll'] = 'true';
      // (Page/PageSize možeš i ne slati – svejedno ih backend ignoriše)
    } else {
      // normalna paginacija
      q['Page'] = page.toString();
      q['PageSize'] = pageSize.toString();
      q['IncludeTotalCount'] = includeTotalCount.toString();
    }

    if (active != null) q['Active'] = active.toString();
    if (fts != null && fts!.isNotEmpty) q['FTS'] = fts;

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

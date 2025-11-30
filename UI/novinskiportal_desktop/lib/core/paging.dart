import 'package:novinskiportal_desktop/core/api_error.dart';

class PagedResult<T> {
  final List<T> items;
  final int? totalCount;
  const PagedResult({required this.items, this.totalCount});
}

List<dynamic> readItems(dynamic data) {
  if (data is Map<String, dynamic>) {
    final raw = data['items'] ?? data['Items'];
    if (raw is List) return raw;
  }
  return const [];
}

int? readTotalCount(dynamic data) {
  if (data is Map<String, dynamic>) {
    final t = data['totalCount'] ?? data['TotalCount'];
    if (t is int) return t;
  }
  return null;
}

List<T> mapListResponse<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromJson,
) {
  // 1) Odgovor je čista lista: [ {..}, {..}, ... ]
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  // 2) Odgovor je objekt koji sadrži listu pod nekim ključem:
  //    items, data, result ili records
  if (data is Map<String, dynamic>) {
    final raw =
        data['items'] ?? data['data'] ?? data['result'] ?? data['records'];

    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }

    // Ako je map prazan, vrati praznu listu umjesto greške
    if (data.isEmpty) return <T>[];
  }

  // 3) Sve ostalo smatra se nevažećim formatom
  throw ApiException(message: 'Neočekivan oblik odgovora.');
}

PagedResult<T> mapPagedResponse<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromJson,
) {
  // Iskoristi postojeći readItems + readTotalCount
  final list = readItems(data);
  final items = list.whereType<Map<String, dynamic>>().map(fromJson).toList();

  final total = readTotalCount(data) ?? items.length;

  return PagedResult<T>(items: items, totalCount: total);
}

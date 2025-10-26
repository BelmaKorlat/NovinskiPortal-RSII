// lib/core/paging.dart
class PagedResult<T> {
  final List<T> items;
  final int? totalCount;
  const PagedResult({required this.items, this.totalCount});
}

/// Sigurno čitanje response polja Items/items i TotalCount/totalCount
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

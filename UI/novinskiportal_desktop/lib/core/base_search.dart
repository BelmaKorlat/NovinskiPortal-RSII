mixin PageArgs {
  int get page;
  int get pageSize;
  bool get includeTotalCount;
  bool get retrieveAll;

  Map<String, dynamic> toPageQuery() {
    final q = <String, dynamic>{};
    if (retrieveAll) {
      q['RetrieveAll'] = 'true';
    } else {
      q['Page'] = page.toString();
      q['PageSize'] = pageSize.toString();
      q['IncludeTotalCount'] = includeTotalCount.toString();
    }
    return q;
  }
}

abstract class BaseSearch with PageArgs {
  final String? fts;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final bool includeTotalCount;
  @override
  final bool retrieveAll;

  const BaseSearch({
    this.fts,
    this.page = 0,
    this.pageSize = 10,
    this.includeTotalCount = true,
    this.retrieveAll = false,
  });

  Map<String, dynamic> toQuery() {
    final q = toPageQuery();
    if (fts != null && fts!.trim().isNotEmpty) q['FTS'] = fts!.trim();
    return q;
  }
}

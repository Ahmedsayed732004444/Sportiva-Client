// One page of a list, whichever way the API describes it (PaginatedList or a { hasMore } list).
class PagedResult<T> {
  const PagedResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) parse) => PagedResult(
    items: (json['items'] as List).cast<Map<String, dynamic>>().map(parse).toList(),
    hasMore: json['hasMore'] as bool? ?? json['hasNextPage'] as bool? ?? false,
  );
}

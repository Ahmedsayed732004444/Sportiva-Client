import 'sport_type.dart';

enum SearchSort {
  nearest('nearest'),
  priceLow('price'),
  priceHigh('priceDesc'),
  rating('rating');

  const SearchSort(this.apiName);

  final String apiName;
}

const _unset = Object();

// Everything the player can narrow the club and court lists by. Prices are in pounds (the API takes piasters).
class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.sport,
    this.governorateId,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.maxKm,
    this.sort = SearchSort.nearest,
  });

  final String query;
  final SportType? sport;
  final int? governorateId;
  final String? city;
  final int? minPrice;
  final int? maxPrice;
  final double? minRating;
  final double? maxKm;
  final SearchSort sort;

  // How many filters are on (not counting the words typed or the sort).
  int get activeCount => [
    sport,
    governorateId,
    if (city?.trim().isNotEmpty ?? false) city,
    if (minPrice != null || maxPrice != null) minPrice ?? maxPrice,
    minRating,
    maxKm,
  ].where((value) => value != null).length;

  bool get isDefault => activeCount == 0 && sort == SearchSort.nearest && query.isEmpty;

  SearchFilters copyWith({
    String? query,
    Object? sport = _unset,
    Object? governorateId = _unset,
    Object? city = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    Object? minRating = _unset,
    Object? maxKm = _unset,
    SearchSort? sort,
  }) => SearchFilters(
    query: query ?? this.query,
    sport: identical(sport, _unset) ? this.sport : sport as SportType?,
    governorateId: identical(governorateId, _unset) ? this.governorateId : governorateId as int?,
    city: identical(city, _unset) ? this.city : city as String?,
    minPrice: identical(minPrice, _unset) ? this.minPrice : minPrice as int?,
    maxPrice: identical(maxPrice, _unset) ? this.maxPrice : maxPrice as int?,
    minRating: identical(minRating, _unset) ? this.minRating : minRating as double?,
    maxKm: identical(maxKm, _unset) ? this.maxKm : maxKm as double?,
    sort: sort ?? this.sort,
  );

  // Keeps the words typed, drops every filter.
  SearchFilters cleared() => SearchFilters(query: query);
}

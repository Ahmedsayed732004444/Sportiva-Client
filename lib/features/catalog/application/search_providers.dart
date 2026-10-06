import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../data/catalog_models.dart';
import '../data/catalog_repository.dart';
import '../data/search_filters.dart';

final searchFiltersProvider = AutoDisposeNotifierProvider<SearchFiltersController, SearchFilters>(
  SearchFiltersController.new,
);

class SearchFiltersController extends AutoDisposeNotifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void set(SearchFilters filters) => state = filters;
  void setQuery(String query) => state = state.copyWith(query: query);
}

final courtSearchProvider = AutoDisposeNotifierProvider<CourtSearchController, PagedState<CourtListItem>>(
  CourtSearchController.new,
);

// Starts over each time the filters change.
class CourtSearchController extends PagedController<CourtListItem> {
  @override
  PagedState<CourtListItem> build() {
    ref.watch(searchFiltersProvider);
    return super.build();
  }

  @override
  Future<PagedResult<CourtListItem>> fetch(int page) async {
    final position = (await ref.read(locationProvider.future)).position;
    return ref.read(catalogRepositoryProvider).searchCourts(ref.read(searchFiltersProvider), at: position, page: page);
  }
}

final clubSearchProvider = AutoDisposeNotifierProvider<ClubSearchController, PagedState<ClubListItem>>(
  ClubSearchController.new,
);

class ClubSearchController extends PagedController<ClubListItem> {
  @override
  PagedState<ClubListItem> build() {
    ref.watch(searchFiltersProvider);
    return super.build();
  }

  @override
  Future<PagedResult<ClubListItem>> fetch(int page) async {
    final position = (await ref.read(locationProvider.future)).position;
    return ref.read(catalogRepositoryProvider).searchClubs(ref.read(searchFiltersProvider), at: position, page: page);
  }
}

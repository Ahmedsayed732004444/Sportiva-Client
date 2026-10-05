import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../data/catalog_models.dart';
import '../data/catalog_repository.dart';
import '../data/sport_type.dart';

// The courts of one sport, nearest first (the API sorts by distance from where the user is).
class CourtsListController extends PagedFamilyController<CourtListItem, SportType> {
  @override
  Future<PagedResult<CourtListItem>> fetch(int page) async {
    // Waits for the location to be known, so the first page already carries distances.
    final position = (await ref.read(locationProvider.future)).position;
    return ref.read(catalogRepositoryProvider).courts(sport: arg, at: position, page: page);
  }
}

final courtsListProvider =
    AutoDisposeNotifierProviderFamily<CourtsListController, PagedState<CourtListItem>, SportType>(
      CourtsListController.new,
    );

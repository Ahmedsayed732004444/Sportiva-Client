import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/location_controller.dart';
import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/data/sport_type.dart';

// The sport picked at the top of the home (null = none yet).
final selectedSportProvider = StateProvider<SportType?>((ref) => null);

// Courts of the picked sport, nearest first (the API sorts by distance from where the user is).
final nearestCourtsProvider = FutureProvider.autoDispose<List<CourtListItem>>((ref) async {
  final sport = ref.watch(selectedSportProvider);
  if (sport == null) return const [];

  final position = ref.watch(locationProvider).valueOrNull?.position;
  final page = await ref.read(catalogRepositoryProvider).courts(sport: sport, at: position);
  return page.items;
});

// Clubs, best rated first, with their distance when the location is known.
final topClubsProvider = AutoDisposeNotifierProvider<TopClubsController, PagedState<ClubListItem>>(
  TopClubsController.new,
);

class TopClubsController extends PagedController<ClubListItem> {
  @override
  PagedState<ClubListItem> build() {
    // A dropped connection came back: what the home shows may have changed.
    final subscription = ref.read(realtimeServiceProvider).on(RealtimeEvents.reconnected).listen((_) => refresh());
    ref.onDispose(subscription.cancel);

    return super.build();
  }

  @override
  Future<PagedResult<ClubListItem>> fetch(int page) async {
    // Waits for the location to be known, so the first page already carries distances.
    final position = (await ref.read(locationProvider.future)).position;
    return ref.read(catalogRepositoryProvider).clubs(at: position, topRated: true, page: page);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/data/sport_type.dart';
import '../data/match_models.dart';
import '../data/match_repository.dart';

// The sport filter of the open matches list (null = all).
final matchSportFilterProvider = StateProvider<SportType?>((ref) => null);

// Refreshes a list when a match changes or the connection came back.
mixin _FollowsMatchChanges on PagedController<FriendlyMatch> {
  void followMatchChanges() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      const names = {RealtimeEvents.matchChanged, RealtimeEvents.joinRequestChanged, RealtimeEvents.reconnected};
      if (names.contains(event.name)) refresh();
    });
    ref.onDispose(subscription.cancel);
  }
}

class OpenMatchesController extends PagedController<FriendlyMatch> with _FollowsMatchChanges {
  @override
  PagedState<FriendlyMatch> build() {
    // Picking another sport rebuilds the list from the first page.
    ref.watch(matchSportFilterProvider);
    followMatchChanges();
    return super.build();
  }

  @override
  Future<PagedResult<FriendlyMatch>> fetch(int page) =>
      ref.read(matchRepositoryProvider).open(sport: ref.read(matchSportFilterProvider), page: page);
}

class MyMatchesController extends PagedController<FriendlyMatch> with _FollowsMatchChanges {
  @override
  PagedState<FriendlyMatch> build() {
    followMatchChanges();
    return super.build();
  }

  @override
  Future<PagedResult<FriendlyMatch>> fetch(int page) => ref.read(matchRepositoryProvider).mine(page: page);
}

final openMatchesProvider = AutoDisposeNotifierProvider<OpenMatchesController, PagedState<FriendlyMatch>>(
  OpenMatchesController.new,
);
final myMatchesProvider = AutoDisposeNotifierProvider<MyMatchesController, PagedState<FriendlyMatch>>(
  MyMatchesController.new,
);

final matchProvider = FutureProvider.autoDispose.family<FriendlyMatch, String>((ref, id) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final same =
        (event.name == RealtimeEvents.matchChanged || event.name == RealtimeEvents.joinRequestChanged) &&
        event.json?['matchId'] == id;
    if (same || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  ref.read(realtimeServiceProvider).invoke('WatchMatch', [id]);
  ref.onDispose(() => ref.read(realtimeServiceProvider).invoke('UnwatchMatch', [id]));

  return ref.read(matchRepositoryProvider).get(id);
});

final joinRequestsProvider = FutureProvider.autoDispose.family<List<JoinRequest>, String>((ref, matchId) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final same = event.name == RealtimeEvents.joinRequestChanged && event.json?['matchId'] == matchId;
    if (same || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  return ref.read(matchRepositoryProvider).joinRequests(matchId);
});

final governoratesProvider = FutureProvider<List<Governorate>>(
  (ref) => ref.read(catalogRepositoryProvider).governorates(),
);

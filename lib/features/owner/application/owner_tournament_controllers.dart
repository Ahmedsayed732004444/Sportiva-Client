import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../tournaments/data/tournament_models.dart';
import '../data/owner_tournament_repository.dart';

class OwnerTournamentsController extends PagedController<TournamentListItem> {
  @override
  PagedState<TournamentListItem> build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.tournamentChanged || event.name == RealtimeEvents.reconnected) refresh();
    });
    ref.onDispose(subscription.cancel);
    return super.build();
  }

  @override
  Future<PagedResult<TournamentListItem>> fetch(int page) =>
      ref.read(ownerTournamentRepositoryProvider).list(page: page);
}

final ownerTournamentsProvider =
    AutoDisposeNotifierProvider<OwnerTournamentsController, PagedState<TournamentListItem>>(
      OwnerTournamentsController.new,
    );

void _follow(Ref ref, String id) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final same = event.name == RealtimeEvents.tournamentChanged && event.json?['tournamentId'] == id;
    if (same || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);
}

final ownerTournamentProvider = FutureProvider.autoDispose.family<Tournament, String>((ref, id) {
  _follow(ref, id);
  return ref.read(ownerTournamentRepositoryProvider).get(id);
});

final ownerTournamentTeamsProvider = FutureProvider.autoDispose.family<List<Team>, String>((ref, id) {
  _follow(ref, id);
  return ref.read(ownerTournamentRepositoryProvider).teams(id);
});

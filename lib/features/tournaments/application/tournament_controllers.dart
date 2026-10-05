import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../catalog/data/sport_type.dart';
import '../data/tournament_models.dart';
import '../data/tournament_repository.dart';

final tournamentSportFilterProvider = StateProvider<SportType?>((ref) => null);
final tournamentOpenOnlyProvider = StateProvider<bool>((ref) => false);

class TournamentsController extends PagedController<TournamentListItem> {
  @override
  PagedState<TournamentListItem> build() {
    // Another filter rebuilds the list from the first page.
    ref.watch(tournamentSportFilterProvider);
    ref.watch(tournamentOpenOnlyProvider);

    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.tournamentChanged || event.name == RealtimeEvents.reconnected) refresh();
    });
    ref.onDispose(subscription.cancel);
    return super.build();
  }

  @override
  Future<PagedResult<TournamentListItem>> fetch(int page) => ref
      .read(tournamentRepositoryProvider)
      .list(sport: ref.read(tournamentSportFilterProvider), openOnly: ref.read(tournamentOpenOnlyProvider), page: page);
}

final tournamentsProvider = AutoDisposeNotifierProvider<TournamentsController, PagedState<TournamentListItem>>(
  TournamentsController.new,
);

// Refetches when the tournament (or, with no id, any of them) changed or the connection came back.
void _followChanges(Ref ref, {String? tournamentId, Set<String> also = const {}}) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final same =
        event.name == RealtimeEvents.tournamentChanged &&
        (tournamentId == null || event.json?['tournamentId'] == tournamentId);
    if (same || also.contains(event.name) || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);
}

final tournamentProvider = FutureProvider.autoDispose.family<Tournament, String>((ref, id) {
  _followChanges(ref, tournamentId: id);

  final realtime = ref.read(realtimeServiceProvider);
  realtime.invoke('WatchTournament', [id]);
  ref.onDispose(() => realtime.invoke('UnwatchTournament', [id]));

  return ref.read(tournamentRepositoryProvider).get(id);
});

final tournamentTeamsProvider = FutureProvider.autoDispose.family<List<Team>, String>((ref, id) {
  _followChanges(ref, tournamentId: id);
  return ref.read(tournamentRepositoryProvider).teams(id);
});

final tournamentMatchesProvider = FutureProvider.autoDispose.family<List<TournamentMatch>, String>((ref, id) {
  _followChanges(ref, tournamentId: id);
  return ref.read(tournamentRepositoryProvider).matches(id);
});

final tournamentStandingsProvider = FutureProvider.autoDispose.family<List<GroupStandings>, String>((ref, id) {
  _followChanges(ref, tournamentId: id);
  return ref.read(tournamentRepositoryProvider).standings(id);
});

final teamProvider = FutureProvider.autoDispose.family<Team, String>((ref, id) {
  _followChanges(ref, also: {RealtimeEvents.paymentChanged});
  return ref.read(tournamentRepositoryProvider).team(id);
});

final myTeamsProvider = FutureProvider.autoDispose<List<Team>>((ref) {
  _followChanges(ref, also: {RealtimeEvents.paymentChanged});
  return ref.read(tournamentRepositoryProvider).myTeams();
});

final invitationsProvider = FutureProvider.autoDispose<List<Invitation>>((ref) {
  _followChanges(ref, also: {RealtimeEvents.receiveNotification});
  return ref.read(tournamentRepositoryProvider).invitations();
});

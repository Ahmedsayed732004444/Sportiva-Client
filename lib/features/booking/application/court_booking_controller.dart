import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/catalog_repository.dart';
import '../data/booking_models.dart';

// How many days ahead a court can be booked (the API generates slots for this many days).
const bookingDaysAhead = 10;

final courtProvider = FutureProvider.autoDispose.family<CourtDetails, String>(
  (ref, id) => ref.read(catalogRepositoryProvider).court(id),
);

class CourtSelection {
  const CourtSelection({
    required this.day,
    required this.durationMinutes,
    required this.part,
    this.playFormat,
    this.startTime,
  });

  final DateTime day;
  final int durationMinutes;
  final CourtPart part;
  final PlayFormat? playFormat;
  // The picked start ("HH:mm:ss"), null until chosen.
  final String? startTime;

  CourtSelection copyWith({
    DateTime? day,
    int? durationMinutes,
    CourtPart? part,
    PlayFormat? playFormat,
    String? startTime,
    bool clearStart = false,
  }) => CourtSelection(
    day: day ?? this.day,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    part: part ?? this.part,
    playFormat: playFormat ?? this.playFormat,
    startTime: clearStart ? null : startTime ?? this.startTime,
  );
}

// What the player has chosen on a court's page. Changing day, length or part drops the picked time.
class CourtSelectionController extends AutoDisposeFamilyNotifier<CourtSelection, CourtDetails> {
  @override
  CourtSelection build(CourtDetails court) => CourtSelection(
    day: today(),
    durationMinutes: court.allowedDurations.contains(court.defaultDurationMinutes)
        ? court.defaultDurationMinutes
        : court.allowedDurations.first,
    part: CourtPart.full,
    playFormat: PlayFormat.appliesTo(court.sport) ? PlayFormat.doubles : null,
  );

  void pickDay(DateTime day) => state = state.copyWith(day: day, clearStart: true);
  void pickDuration(int minutes) => state = state.copyWith(durationMinutes: minutes, clearStart: true);
  void pickPart(CourtPart part) => state = state.copyWith(part: part, clearStart: true);
  void pickFormat(PlayFormat format) => state = state.copyWith(playFormat: format);
  void pickStart(String? startTime) => state = state.copyWith(startTime: startTime, clearStart: startTime == null);
}

final courtSelectionProvider =
    AutoDisposeNotifierProviderFamily<CourtSelectionController, CourtSelection, CourtDetails>(
      CourtSelectionController.new,
    );

// The day's 30-minute units of a court. Joins the court's live group and reloads when somebody books or frees a time.
final availabilityProvider = FutureProvider.autoDispose.family<List<SlotUnit>, ({String courtId, DateTime day})>((
  ref,
  key,
) async {
  final realtime = ref.read(realtimeServiceProvider);
  final dayText = apiDay(key.day);

  realtime.invoke('WatchCourt', [key.courtId, dayText]);
  ref.onDispose(() => realtime.invoke('UnwatchCourt', [key.courtId, dayText]));

  final subscription = realtime.events.listen((event) {
    final json = event.json;
    final changed =
        event.name == RealtimeEvents.slotsChanged && json?['courtId'] == key.courtId && json?['day'] == dayText;
    if (changed || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  return ref.read(catalogRepositoryProvider).availability(key.courtId, key.day);
});

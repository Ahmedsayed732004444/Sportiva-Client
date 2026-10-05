import '../data/booking_models.dart';

// A start time the player can pick, with what the whole booking would cost.
class BookableStart {
  const BookableStart({required this.startTime, required this.endTime, required this.pricePiasters});

  final String startTime;
  final String endTime;
  final int pricePiasters;
}

// Which start times fit a chosen duration and court part. A booking takes consecutive units, all free for that part
// (a full court needs both halves free). Pure logic: the API still has the last word (it re-checks and prices).
abstract final class SlotPlanner {
  static const unitMinutes = 30;

  static List<BookableStart> starts(List<SlotUnit> units, {required int durationMinutes, required CourtPart part}) {
    final needed = durationMinutes ~/ unitMinutes;
    if (needed < 1) return const [];

    final result = <BookableStart>[];
    for (var i = 0; i + needed <= units.length; i++) {
      final run = units.sublist(i, i + needed);
      if (_isFreeRun(run, part)) {
        result.add(
          BookableStart(startTime: run.first.startTime, endTime: run.last.endTime, pricePiasters: price(run, part)),
        );
      }
    }
    return result;
  }

  static bool _isFreeRun(List<SlotUnit> run, CourtPart part) {
    for (var i = 0; i < run.length; i++) {
      if (i > 0 && run[i].startTime != run[i - 1].endTime) return false;
      if (!_isFree(run[i], part)) return false;
    }
    return true;
  }

  static bool _isFree(SlotUnit unit, CourtPart part) {
    if (unit.status == SlotStatus.booked || unit.status == SlotStatus.closed || unit.status == SlotStatus.past) {
      return false;
    }
    return part == CourtPart.full
        ? unit.freeParts.contains(CourtPart.halfA) && unit.freeParts.contains(CourtPart.halfB)
        : unit.freeParts.contains(part);
  }

  // Each unit is priced at its own hourly rate (evening rates can differ), for half a court at the half-court rate.
  static int price(List<SlotUnit> run, CourtPart part) => run.fold(0, (sum, unit) {
    final hourly = part == CourtPart.full
        ? unit.pricePerHourPiasters
        : (unit.halfCourtPricePerHourPiasters ?? unit.pricePerHourPiasters);
    return sum + hourly * unitMinutes ~/ 60;
  });
}

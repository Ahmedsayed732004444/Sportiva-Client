import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/features/booking/data/booking_models.dart';
import 'package:sportiva_app/features/booking/data/recurring_models.dart';
import 'package:sportiva_app/features/owner/data/report_models.dart';

void main() {
  test('a weekly booking reads its weekday by name and keeps what can be done with it', () {
    final booking = RecurringBooking.fromJson({
      'id': 'r1',
      'status': 'Confirmed',
      'courtName': 'Court',
      'sportType': 'Football',
      'club': {'id': 'c', 'name': 'Club', 'governorateName': 'G', 'city': 'C'},
      'dayOfWeek': 'Wednesday',
      'startTime': '17:00:00',
      'durationMinutes': 60,
      'firstDay': '2026-11-04',
      'weeks': 3,
      'canCancel': true,
      'customerName': 'Ali',
    });
    expect(
      (booking.dayOfWeek, booking.status, booking.weeks, booking.canCancel, booking.canRespond),
      (3, RecurringStatus.confirmed, 3, true, false),
    );
  });

  test('the request is what the API wants', () {
    const request = RecurringRequest(
      courtId: 'k',
      firstDay: '2026-11-04',
      startTime: '17:00:00',
      durationMinutes: 60,
      part: CourtPart.halfA,
      weeks: 4,
      skipUnavailable: true,
    );
    expect(request.toJson(), containsPair('courtPart', 'HalfA'));
    expect(request.toJson(), containsPair('skipUnavailableWeeks', true));
  });

  test('a preview counts the free weeks', () {
    final preview = RecurringPreview.fromJson({
      'weeks': [
        {'day': '2026-11-04', 'isAvailable': true, 'pricePiasters': 45000},
        {'day': '2026-11-11', 'isAvailable': false, 'pricePiasters': 45000},
      ],
      'availableWeeks': 1,
      'totalPricePiasters': 45000,
    });
    expect((preview.availableWeeks, preview.weeks.last.isAvailable, preview.totalPiasters), (1, false, 45000));
  });

  test('a club report reads its counts, courts and peak hours', () {
    final report = ClubReport.fromJson({
      'revenuePiasters': 90000,
      'counts': {
        'total': 4,
        'pending': 0,
        'confirmed': 1,
        'completed': 2,
        'cancelled': 1,
        'rejected': 0,
        'noShow': 0,
        'expired': 0,
      },
      'occupancy': [
        {'courtId': 'k', 'courtName': 'Main', 'bookedHours': 3.5, 'availableHours': 70, 'occupancyRate': 0.05},
      ],
      'peakHours': [
        {'dayOfWeek': 'Friday', 'hour': 20, 'bookedHours': 2},
      ],
      'noShowRate': 0.0,
      'sources': [
        {'source': 'App', 'count': 3, 'revenuePiasters': 70000},
      ],
      'ratings': {'averageRating': 4.5, 'reviewsCount': 2},
      'topCustomers': [],
    });
    expect(
      (
        report.revenuePiasters,
        report.total,
        report.occupancy.single.rate,
        report.peakHours.single.dayOfWeek,
        report.averageRating,
      ),
      (90000, 4, 0.05, 5, 4.5),
    );
  });
}

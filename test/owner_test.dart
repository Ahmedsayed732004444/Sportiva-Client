import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/core/localization/price_format.dart';
import 'package:sportiva_app/features/booking/data/booking_models.dart';
import 'package:sportiva_app/features/owner/data/owner_club_models.dart';
import 'package:sportiva_app/features/owner/data/owner_court_models.dart';
import 'package:sportiva_app/features/settings/data/account_repository.dart';

Map<String, dynamic> bookingJson(Map<String, dynamic> extra) => {
  'id': 'b1',
  'code': 'C1',
  'status': 'Pending',
  'courtName': 'Court',
  'sportType': 'Football',
  'club': {'id': 'c', 'name': 'Club', 'governorateName': 'G', 'city': 'C'},
  'day': '2026-11-01',
  'startTime': '20:00:00',
  'endTime': '21:00:00',
  'durationMinutes': 60,
  'pricePiasters': 45000,
  ...extra,
};

void main() {
  test('a booking carries what the club can do with it and who booked', () {
    final booking = Booking.fromJson(
      bookingJson({
        'canRespond': true,
        'canCancel': true,
        'canOpenMatch': true,
        'canReview': true,
        'customerName': 'Ali',
        'customerRating': 4.5,
        'customerReviewsCount': 3,
        'matchId': 'm1',
      }),
    );
    expect((booking.canRespond, booking.canOpenMatch, booking.canReview, booking.matchId), (true, true, true, 'm1'));
    expect((booking.customerName, booking.customerRating, booking.customerReviewsCount), ('Ali', 4.5, 3));
    expect(booking.copyWith(status: BookingStatus.confirmed).canOpenMatch, isTrue);
  });

  test('a booking without those flags has none of them', () {
    final booking = Booking.fromJson(bookingJson({}));
    expect(
      (booking.canRespond, booking.canComplete, booking.canOpenMatch, booking.matchId),
      (false, false, false, null),
    );
  });

  test('a price rule reads the weekday by number or name and writes it back', () {
    expect(
      PriceRule.fromJson({
        'dayOfWeek': 'Friday',
        'startTime': '18:00:00',
        'endTime': '23:00:00',
        'pricePerHourPiasters': 30000,
      }).dayOfWeek,
      5,
    );
    expect(
      PriceRule.fromJson({
        'dayOfWeek': null,
        'startTime': '10:00:00',
        'endTime': '12:00:00',
        'pricePerHourPiasters': 100,
      }).dayOfWeek,
      isNull,
    );
    const rule = PriceRule(
      dayOfWeek: 2,
      startTime: '10:00:00',
      endTime: '12:00:00',
      pricePiasters: 100,
      halfCourtPiasters: 60,
    );
    expect(rule.toJson()['halfCourtPricePerHourPiasters'], 60);
  });

  test('typed prices become piasters', () {
    expect(parsePiasters('150'), 15000);
    expect(parsePiasters('150.5'), 15050);
    expect(parsePiasters('12,5'), 1250);
    expect(parsePiasters('abc'), isNull);
    expect(parsePiasters('-3'), isNull);
  });

  test('roles decide whether the club section is offered', () {
    AccountProfile profile(List<String> roles) => AccountProfile.fromJson({
      'firstName': 'A',
      'lastName': 'B',
      'email': 'a@b.c',
      'preferredLanguage': 'Arabic',
      'roles': roles,
    });
    expect(profile(['Member']).managesClub, isFalse);
    expect(profile(['Member', 'Staff']).managesClub, isTrue);
    expect(profile(['Owner']).isOwner, isTrue);
    expect(profile(['Member']).languageCode, 'ar');
  });

  test('notification types are grouped, and a subscription state is read', () {
    expect(SubscriptionState.fromApi('GracePeriod'), SubscriptionState.gracePeriod);
    expect(SubscriptionState.fromApi(null), SubscriptionState.none);
    expect(StaffPermission.fromApi('ManageBookings'), StaffPermission.manageBookings);
    expect(StaffPermission.fromApi('Nope'), isNull);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportiva_app/core/localization/locale_controller.dart';
import 'package:sportiva_app/core/theme/app_theme.dart';
import 'package:sportiva_app/features/booking/data/booking_models.dart';
import 'package:sportiva_app/features/booking/data/booking_repository.dart';
import 'package:sportiva_app/features/booking/domain/slot_planner.dart';
import 'package:sportiva_app/features/booking/presentation/court_screen.dart';
import 'package:sportiva_app/features/catalog/data/catalog_models.dart';
import 'package:sportiva_app/features/catalog/data/catalog_repository.dart';
import 'package:sportiva_app/features/catalog/data/sport_type.dart';
import 'package:sportiva_app/core/network/api_exception.dart';
import 'package:sportiva_app/l10n/app_localizations.dart';

SlotUnit unit(
  String start,
  String end, {
  SlotStatus status = SlotStatus.available,
  Set<CourtPart>? free,
  int price = 40000,
  int? half,
}) => SlotUnit(
  startTime: start,
  endTime: end,
  status: status,
  freeParts: free ?? {CourtPart.halfA, CourtPart.halfB},
  pricePerHourPiasters: price,
  halfCourtPricePerHourPiasters: half,
);

// 16:00 - 19:00 in 30-minute units.
List<SlotUnit> evening({Map<int, SlotUnit> overrides = const {}}) {
  final times = ['16:00:00', '16:30:00', '17:00:00', '17:30:00', '18:00:00', '18:30:00', '19:00:00'];
  return [for (var i = 0; i < times.length - 1; i++) overrides[i] ?? unit(times[i], times[i + 1])];
}

void main() {
  group('SlotPlanner', () {
    test('every start that fits the duration is offered, with the right price', () {
      final starts = SlotPlanner.starts(evening(), durationMinutes: 60, part: CourtPart.full);
      expect(starts.map((s) => s.startTime), ['16:00:00', '16:30:00', '17:00:00', '17:30:00', '18:00:00']);
      expect(starts.first.endTime, '17:00:00');
      expect(starts.first.pricePiasters, 40000);
    });

    test('a booked unit removes the starts that would cover it', () {
      final units = evening(
        overrides: {2: unit('17:00:00', '17:30:00', status: SlotStatus.booked, free: {})},
      );
      final starts = SlotPlanner.starts(units, durationMinutes: 60, part: CourtPart.full);
      expect(starts.map((s) => s.startTime), ['16:00:00', '17:30:00', '18:00:00']);
    });

    test('a full court needs both halves free, a half only its own', () {
      final units = evening(
        overrides: {
          0: unit('16:00:00', '16:30:00', status: SlotStatus.partiallyBooked, free: {CourtPart.halfB}),
        },
      );
      expect(
        SlotPlanner.starts(units, durationMinutes: 30, part: CourtPart.full).map((s) => s.startTime),
        isNot(contains('16:00:00')),
      );
      expect(
        SlotPlanner.starts(units, durationMinutes: 30, part: CourtPart.halfA).map((s) => s.startTime),
        isNot(contains('16:00:00')),
      );
      expect(
        SlotPlanner.starts(units, durationMinutes: 30, part: CourtPart.halfB).map((s) => s.startTime),
        contains('16:00:00'),
      );
    });

    test('units must follow each other with no gap', () {
      final units = [unit('16:00:00', '16:30:00'), unit('17:00:00', '17:30:00')];
      expect(SlotPlanner.starts(units, durationMinutes: 60, part: CourtPart.full), isEmpty);
    });

    test('each unit is priced at its own rate, half courts at the half rate', () {
      final units = [
        unit('19:30:00', '20:00:00', price: 40000, half: 24000),
        unit('20:00:00', '20:30:00', price: 60000, half: 36000),
      ];
      expect(SlotPlanner.starts(units, durationMinutes: 60, part: CourtPart.full).single.pricePiasters, 50000);
      expect(SlotPlanner.starts(units, durationMinutes: 60, part: CourtPart.halfA).single.pricePiasters, 30000);
    });

    test('closed and past units are never offered', () {
      final units = [
        unit('10:00:00', '10:30:00', status: SlotStatus.past),
        unit('10:30:00', '11:00:00', status: SlotStatus.closed),
      ];
      expect(SlotPlanner.starts(units, durationMinutes: 30, part: CourtPart.full), isEmpty);
    });

    test('a booking that crosses midnight is still consecutive', () {
      final units = [unit('23:30:00', '00:00:00'), unit('00:00:00', '00:30:00')];
      expect(SlotPlanner.starts(units, durationMinutes: 60, part: CourtPart.full).single.endTime, '00:30:00');
    });
  });

  test('models read the API', () {
    final booking = Booking.fromJson({
      'id': 'b1',
      'code': 'BK-100001',
      'status': 'Pending',
      'courtName': 'Pitch',
      'sportType': 'Football',
      'club': {'id': 'k', 'name': 'Club'},
      'clubPhone': '010',
      'day': '2026-10-06',
      'startTime': '16:00:00',
      'endTime': '17:00:00',
      'durationMinutes': 60,
      'pricePiasters': 40000,
      'canCancel': true,
    });
    expect(booking.status, BookingStatus.pending);
    expect(booking.isActive, isTrue);
    expect(booking.copyWith(status: BookingStatus.cancelled).isActive, isFalse);

    final slot = SlotUnit.fromJson({
      'startTime': '10:00:00',
      'endTime': '10:30:00',
      'status': 'PartiallyBooked',
      'freeParts': ['HalfA'],
      'pricePerHourPiasters': 30000,
      'halfCourtPricePerHourPiasters': 18000,
    });
    expect(slot.status, SlotStatus.partiallyBooked);
    expect(slot.freeParts, {CourtPart.halfA});
  });

  group('court screen', () {
    testWidgets('picks a day, a time and books through the repository', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(420, 1600);
      addTearDown(tester.view.reset);
      await initializeDateFormatting();

      final catalog = _FakeCatalog();
      final bookings = _FakeBookings();
      SharedPreferences.setMockInitialValues({'locale': 'en'});
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            catalogRepositoryProvider.overrideWithValue(catalog),
            bookingRepositoryProvider.overrideWithValue(bookings),
          ],
          child: MaterialApp(
            theme: AppTheme.build(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const CourtScreen(courtId: 'c1'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pitch A'), findsWidgets);
      expect(find.text('Choose the time'), findsOneWidget);
      expect(find.text('60 min'), findsOneWidget);

      final bookButton = find.widgetWithText(ElevatedButton, 'Book now');
      expect(tester.widget<ElevatedButton>(bookButton).onPressed, isNull, reason: 'no time picked yet');

      await tester.tap(find.textContaining('4:00'));
      await tester.pump();
      expect(find.text('400 EGP'), findsWidgets, reason: 'the total');
      expect(tester.widget<ElevatedButton>(bookButton).onPressed, isNotNull);

      await tester.tap(bookButton);
      await tester.pumpAndSettle();
      expect(find.text('Booking summary'), findsOneWidget);

      await tester.tap(find.text('Confirm booking'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(bookings.created, hasLength(1));
      expect(bookings.created.single, contains('16:00:00'));
      expect(bookings.created.single, contains('60'));
    });
  });
}

class _FakeCatalog extends CatalogRepository {
  _FakeCatalog() : super(Dio());

  @override
  Future<CourtDetails> court(String id) async => const CourtDetails(
    id: 'c1',
    name: 'Pitch A',
    sport: SportType.football,
    club: ClubRef(id: 'k1', name: 'Nile Club'),
    pricePerHourPiasters: 40000,
    allowsHalfCourt: false,
    allowedDurations: [60, 90],
    defaultDurationMinutes: 60,
    maxPlayers: 10,
    isAutomatic: true,
    canBook: true,
  );

  @override
  Future<List<SlotUnit>> availability(String courtId, DateTime day) async => evening();
}

class _FakeBookings extends BookingRepository {
  _FakeBookings() : super(Dio());

  final created = <String>[];

  @override
  Future<Booking> create({
    required String courtId,
    required DateTime day,
    required String startTime,
    required int durationMinutes,
    required CourtPart part,
    PlayFormat? playFormat,
  }) async {
    created.add('$courtId $startTime $durationMinutes ${part.apiName}');
    throw const ApiException(kind: ApiErrorKind.server, message: 'stop here');
  }
}

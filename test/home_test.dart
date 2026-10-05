import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportiva_app/core/localization/locale_controller.dart';
import 'package:sportiva_app/core/localization/price_format.dart';
import 'package:sportiva_app/core/location/coordinates.dart';
import 'package:sportiva_app/core/location/location_controller.dart';
import 'package:sportiva_app/core/location/location_service.dart';
import 'package:sportiva_app/core/paging/paged_result.dart';
import 'package:sportiva_app/core/theme/app_theme.dart';
import 'package:sportiva_app/features/catalog/data/catalog_models.dart';
import 'package:sportiva_app/features/catalog/data/catalog_repository.dart';
import 'package:sportiva_app/features/catalog/data/sport_type.dart';
import 'package:sportiva_app/features/home/presentation/home_screen.dart';
import 'package:sportiva_app/features/location/location_gate_screen.dart';
import 'package:sportiva_app/l10n/app_localizations.dart';

class FakeLocation extends LocationService {
  FakeLocation({this.start = LocationAccess.denied, this.afterRequest = LocationAccess.granted});

  final LocationAccess start;
  final LocationAccess afterRequest;
  int requests = 0;

  @override
  Future<LocationAccess> access() async => start;

  @override
  Future<LocationAccess> request() async {
    requests++;
    return afterRequest;
  }

  @override
  Future<Coordinates?> position() async => const Coordinates(30.05, 31.33);
}

class FakeCatalog extends CatalogRepository {
  FakeCatalog() : super(Dio());

  final calls = <String>[];

  @override
  Future<PagedResult<CourtListItem>> courts({
    required SportType sport,
    Coordinates? at,
    int page = 1,
    int pageSize = 10,
  }) async {
    calls.add('courts ${sport.apiName} near=${at != null}');
    return PagedResult(
      items: [
        CourtListItem(
          id: 'c1',
          name: 'Pitch A',
          sport: sport,
          pricePerHourPiasters: 40000,
          club: const ClubRef(id: 'k1', name: 'Nile Club', logoUrl: 'https://x/logo.png'),
          distanceText: '1.2 km',
          averageRating: 4.5,
          reviewsCount: 8,
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<PagedResult<ClubListItem>> clubs({
    Coordinates? at,
    bool topRated = false,
    int page = 1,
    int pageSize = 10,
  }) async {
    calls.add('clubs topRated=$topRated near=${at != null}');
    return const PagedResult(
      items: [
        ClubListItem(
          id: 'k1',
          name: 'Nile Club',
          sports: [SportType.football, SportType.padel],
          courtsCount: 2,
          city: 'Giza',
          averageRating: 4.8,
          reviewsCount: 12,
          distanceText: '1.2 km',
        ),
      ],
      hasMore: false,
    );
  }
}

Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  required FakeLocation location,
  FakeCatalog? catalog,
  String language = 'en',
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        locationServiceProvider.overrideWithValue(location),
        if (catalog != null) catalogRepositoryProvider.overrideWithValue(catalog),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  test('court and club models read the API', () {
    final court = CourtListItem.fromJson({
      'id': 'c',
      'name': 'Pitch',
      'sportType': 'Padel',
      'pricePerHourPiasters': 45050,
      'club': {'id': 'k', 'name': 'Club', 'logoUrl': 'https://x/club.png', 'city': 'Giza'},
      'coverImageUrl': 'https://x/court.png',
      'distanceText': '3 km',
      'averageRating': 4,
      'reviewsCount': 2,
    });
    expect(court.sport, SportType.padel);
    expect(court.imageUrl, 'https://x/club.png', reason: 'a court shows its club picture');
    expect(
      CourtListItem.fromJson({
        ...{
          'id': 'c',
          'name': 'P',
          'sportType': 'Football',
          'pricePerHourPiasters': 1,
          'club': {'id': 'k', 'name': 'C'},
        },
        'coverImageUrl': 'https://x/court.png',
      }).imageUrl,
      'https://x/court.png',
    );

    final club = ClubListItem.fromJson({
      'id': 'k',
      'name': 'Club',
      'sports': ['Football', 'Padel'],
      'courtsCount': 3,
      'coverUrl': 'https://x/cover.png',
      'logoUrl': 'https://x/logo.png',
    });
    expect(club.sports, [SportType.football, SportType.padel]);
    expect(club.imageUrl, 'https://x/cover.png');
  });

  test('prices show whole pounds without decimals', () {
    expect(formatPounds(30000), '300');
    expect(formatPounds(45050), '450.50');
  });

  test('the home offers football, padel and basketball', () {
    expect(SportType.homeSports, [SportType.football, SportType.padel, SportType.basketball]);
  });

  testWidgets('the gate asks for the location and lets the home open once allowed', (tester) async {
    final location = FakeLocation();
    await pumpApp(tester, const LocationGateScreen(), location: location);

    expect(find.text('Find courts near you'), findsOneWidget);
    await tester.tap(find.text('Allow location'));
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(tester.element(find.byType(LocationGateScreen)));
    expect(location.requests, 1);
    expect(container.read(locationProvider).value!.decided, isTrue);
    expect(container.read(locationProvider).value!.hasPosition, isTrue);
  });

  testWidgets('"Not now" lets the user in without a location', (tester) async {
    await pumpApp(tester, const LocationGateScreen(), location: FakeLocation(afterRequest: LocationAccess.denied));

    await tester.tap(find.text('Not now'));
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(tester.element(find.byType(LocationGateScreen)));
    expect(container.read(locationProvider).value!.decided, isTrue);
    expect(container.read(locationProvider).value!.hasPosition, isFalse);
  });

  testWidgets('home: sports on top, tapping one shows its nearest courts, best rated clubs below', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 1200);
    addTearDown(tester.view.reset);

    final catalog = FakeCatalog();
    await pumpApp(
      tester,
      const HomeScreen(),
      location: FakeLocation(start: LocationAccess.granted),
      catalog: catalog,
    );

    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Padel'), findsOneWidget);
    expect(find.text('Basketball'), findsOneWidget);
    expect(find.text('Top rated clubs'), findsOneWidget);
    expect(find.text('Nile Club'), findsOneWidget, reason: 'the top club is listed');
    expect(find.text('Pitch A'), findsNothing, reason: 'no sport picked yet');
    expect(catalog.calls, contains('clubs topRated=true near=true'));

    await tester.tap(find.text('Padel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Pitch A'), findsOneWidget);
    expect(find.text('400 EGP / hr'), findsOneWidget);
    expect(find.text('Courts near you · Padel'), findsOneWidget);
    expect(catalog.calls, contains('courts Padel near=true'));

    await tester.tap(find.text('Padel'));
    await tester.pump();
    expect(find.text('Pitch A'), findsNothing, reason: 'tapping the sport again clears it');
  });

  testWidgets('home in Arabic', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 1200);
    addTearDown(tester.view.reset);

    await pumpApp(
      tester,
      const HomeScreen(),
      location: FakeLocation(start: LocationAccess.granted),
      catalog: FakeCatalog(),
      language: 'ar',
    );
    expect(find.text('كرة قدم'), findsOneWidget);
    expect(find.text('الأندية الأعلى تقييماً'), findsOneWidget);
  });
}

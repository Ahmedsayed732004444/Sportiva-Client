import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/core/network/api_exception.dart';
import 'package:sportiva_app/core/paging/paged_controller.dart';
import 'package:sportiva_app/core/paging/paged_result.dart';
import 'package:sportiva_app/core/realtime/realtime_service.dart';
import 'package:sportiva_app/core/widgets/app_bottom_nav.dart';
import 'package:sportiva_app/features/notifications/data/app_notification.dart';

class _Numbers extends PagedController<int> {
  static int calls = 0;
  static bool fail = false;

  @override
  Future<PagedResult<int>> fetch(int page) async {
    calls++;
    if (fail) throw const ApiException(kind: ApiErrorKind.network);
    return PagedResult(items: List.generate(3, (i) => (page - 1) * 3 + i), hasMore: page < 3);
  }
}

final _numbers = AutoDisposeNotifierProvider<_Numbers, PagedState<int>>(_Numbers.new);

void main() {
  group('PagedController', () {
    late ProviderContainer container;

    setUp(() {
      _Numbers.calls = 0;
      _Numbers.fail = false;
      container = ProviderContainer();
      container.listen(_numbers, (_, _) {});
    });
    tearDown(() => container.dispose());

    test('loads page after page until there are no more', () async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(container.read(_numbers).items, [0, 1, 2]);

      await container.read(_numbers.notifier).loadMore();
      await container.read(_numbers.notifier).loadMore();
      expect(container.read(_numbers).items.length, 9);
      expect(container.read(_numbers).hasMore, isFalse);

      await container.read(_numbers.notifier).loadMore();
      expect(_Numbers.calls, 3);
    });

    test('keeps the loaded items when a page fails and retries it', () async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      _Numbers.fail = true;
      await container.read(_numbers.notifier).loadMore();
      expect(container.read(_numbers).error?.kind, ApiErrorKind.network);
      expect(container.read(_numbers).items.length, 3);

      _Numbers.fail = false;
      await container.read(_numbers.notifier).loadMore();
      expect(container.read(_numbers).items.length, 6);
      expect(container.read(_numbers).error, isNull);
    });

    test('refresh starts over', () async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await container.read(_numbers.notifier).refresh();
      expect(container.read(_numbers).items, [0, 1, 2]);
    });
  });

  test('PagedResult reads both list shapes', () {
    final a = PagedResult.fromJson({
      'items': [
        {'v': 1},
      ],
      'hasMore': true,
    }, (j) => j['v']);
    final b = PagedResult.fromJson({
      'items': [
        {'v': 2},
      ],
      'hasNextPage': true,
    }, (j) => j['v']);
    expect(a.hasMore, isTrue);
    expect(b.hasMore, isTrue);
    expect(b.items, [2]);
  });

  test('a notification reads from the list and from the realtime push', () {
    final pushed = AppNotification.fromJson({
      'notificationId': 'n1',
      'type': 'NewFollower',
      'title': 'New follower',
      'body': 'Hi',
    });
    expect(pushed.isRead, isFalse);
    expect(pushed.type, 'NewFollower');

    final listed = AppNotification.fromJson({
      'notificationId': 'n2',
      'type': 'BookingConfirmed',
      'title': 't',
      'body': 'b',
      'isRead': true,
      'createdAt': '2026-10-05T10:00:00Z',
      'actor': {'userId': 'u', 'fullName': 'Ali Hassan'},
    });
    expect(listed.isRead, isTrue);
    expect(listed.actorName, 'Ali Hassan');
    expect(listed.asRead().id, 'n2');
  });

  test('realtime events carry their first argument', () {
    expect(const RealtimeEvent('X', {'a': 1}).json, {'a': 1});
    expect(const RealtimeEvent('X', 5).json, isNull);
    expect(RealtimeEvents.all, contains(RealtimeEvents.tournamentChanged));
  });
  testWidgets('bottom bar marks the current tab and reports taps', (tester) async {
    var tapped = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 1,
            onTap: (i) => tapped = i,
            items: const [
              AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
              AppNavItem(icon: Icons.sports_soccer_outlined, activeIcon: Icons.sports_soccer, label: 'Matches'),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    await tester.tap(find.text('Home'));
    expect(tapped, 0);
  });
}

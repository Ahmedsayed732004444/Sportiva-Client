import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../data/app_notification.dart';
import '../data/notifications_repository.dart';

// How many notifications are unread: the badge on the bell. The API pushes the new count after every change.
final unreadCountProvider = NotifierProvider<UnreadCountController, int>(UnreadCountController.new);

class UnreadCountController extends Notifier<int> {
  @override
  int build() {
    final realtime = ref.watch(realtimeServiceProvider);

    final subscription = realtime.events.listen((event) {
      switch (event.name) {
        case RealtimeEvents.unreadCountUpdated:
          if (event.data is int) state = event.data! as int;
        case RealtimeEvents.reconnected:
          _load();
      }
    });
    ref.onDispose(subscription.cancel);

    _load();
    return 0;
  }

  Future<void> _load() async {
    try {
      state = await ref.read(notificationsRepositoryProvider).unreadCount();
    } on ApiException {
      // The badge just stays as it was.
    }
  }
}

final notificationsProvider = AutoDisposeNotifierProvider<NotificationsController, PagedState<AppNotification>>(
  NotificationsController.new,
);

class NotificationsController extends PagedController<AppNotification> {
  @override
  PagedState<AppNotification> build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      switch (event.name) {
        case RealtimeEvents.receiveNotification:
          if (event.json case final json?) prepend(AppNotification.fromJson(json));
        case RealtimeEvents.reconnected:
          refresh();
      }
    });
    ref.onDispose(subscription.cancel);

    return super.build();
  }

  @override
  Future<PagedResult<AppNotification>> fetch(int page) => ref.read(notificationsRepositoryProvider).list(page);

  Future<void> open(AppNotification notification) async {
    if (notification.isRead) return;
    replaceWhere((n) => n.id == notification.id, (n) => n.asRead());
    await _quiet(() => ref.read(notificationsRepositoryProvider).markRead(notification.id));
  }

  Future<void> markAllRead() async {
    state = state.copyWith(items: [for (final n in state.items) n.asRead()]);
    await _quiet(() => ref.read(notificationsRepositoryProvider).markAllRead());
  }

  Future<void> remove(AppNotification notification) async {
    removeWhere((n) => n.id == notification.id);
    await _quiet(() => ref.read(notificationsRepositoryProvider).delete(notification.id));
  }

  // The screen already shows the result; a failure here is fixed by the next refresh.
  Future<void> _quiet(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException {
      // ignored on purpose
    }
  }
}

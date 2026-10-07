import '../../chat/application/chat_controller.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../data/app_notification.dart';
import 'notification_routes.dart';

// A notification that arrives while the app is running also shows up the way phone notifications do: in the
// system tray, with sound and vibration, and tapping it opens the exact screen it is about.
// (When the app is fully closed nothing reaches the phone yet: that needs push messages from a push service.)
class SystemNotifications {
  SystemNotifications(this._ref);

  final Ref _ref;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'sportiva_alerts';

  Future<void> start() async {
    if (kIsWeb || _ready) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) => _open(response.payload),
    );
    _ready = true;

    final l10n = lookupAppLocalizations(_ref.read(localeProvider));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId,
            l10n.notificationChannelName,
            description: l10n.notificationChannelDescription,
            importance: Importance.high,
          ),
        );

    await _askPermission();

    // The app was opened by tapping a notification while it was closed.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) _open(launch!.notificationResponse?.payload);
  }

  Future<void> _askPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> show(AppNotification notification) async {
    if (!_ready) return;
    // A message from the person whose chat is open is already on screen.
    if (notification.entityType == 'ApplicationUser' && notification.entityId == _ref.read(openChatUserProvider)) {
      return;
    }

    final l10n = lookupAppLocalizations(_ref.read(localeProvider));
    final route = notificationRoute(notification);

    await _plugin.show(
      id: notification.id.hashCode & 0x7fffffff,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          l10n.notificationChannelName,
          channelDescription: l10n.notificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(notification.body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      payload: jsonEncode({'route': route}),
    );
  }

  void _open(String? payload) {
    if (payload == null) return;
    try {
      final route = (jsonDecode(payload) as Map<String, dynamic>)['route'] as String?;
      if (route != null) _ref.read(routerProvider).push(route);
    } on FormatException {
      // A payload we didn't write: nothing to open.
    }
  }
}

final systemNotificationsProvider = Provider<SystemNotifications>((ref) {
  final service = SystemNotifications(ref);

  // Started once somebody is signed in (the permission prompt belongs after the login, not on the first screen).
  ref.listen(authControllerProvider, (_, next) {
    if (next.valueOrNull != null) service.start();
  }, fireImmediately: true);

  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final json = event.json;
    if (event.name == RealtimeEvents.receiveNotification && json != null) {
      service.show(AppNotification.fromJson(json));
    }
  });
  ref.onDispose(subscription.cancel);

  return service;
});

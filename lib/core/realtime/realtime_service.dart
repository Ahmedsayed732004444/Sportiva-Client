import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/app_config.dart';
import '../storage/session_store.dart';

// Every event the API pushes (see Contracts/Realtime/RealtimeEvents.cs and RealtimeHub.IRealtimeClient).
abstract final class RealtimeEvents {
  static const receiveNotification = 'ReceiveNotification';
  static const unreadCountUpdated = 'UnreadCountUpdated';
  static const bookingChanged = 'BookingChanged';
  static const recurringBookingChanged = 'RecurringBookingChanged';
  static const slotsChanged = 'SlotsChanged';
  static const matchChanged = 'MatchChanged';
  static const joinRequestChanged = 'JoinRequestChanged';
  static const paymentChanged = 'PaymentChanged';
  static const membershipChanged = 'MembershipChanged';
  static const clubChanged = 'ClubChanged';
  static const reviewChanged = 'ReviewChanged';
  static const postChanged = 'PostChanged';
  static const commentChanged = 'CommentChanged';
  static const newPost = 'NewPost';
  static const profileChanged = 'ProfileChanged';
  static const messageReceived = 'MessageReceived';
  static const messagesRead = 'MessagesRead';
  static const typing = 'Typing';
  static const presenceChanged = 'PresenceChanged';
  static const tournamentChanged = 'TournamentChanged';
  static const sessionEnded = 'SessionEnded';
  static const plansChanged = 'PlansChanged';

  // Raised by the app itself after a dropped connection came back: screens refetch what they show.
  static const reconnected = '__reconnected';

  static const all = [
    receiveNotification, unreadCountUpdated, bookingChanged, recurringBookingChanged, slotsChanged, matchChanged,
    joinRequestChanged, paymentChanged, membershipChanged, clubChanged, reviewChanged, postChanged, commentChanged,
    newPost, profileChanged, messageReceived, messagesRead, typing, presenceChanged, tournamentChanged, sessionEnded,
    plansChanged, //
  ];
}

class RealtimeEvent {
  const RealtimeEvent(this.name, [this.data]);

  final String name;
  // The first argument of the event: a JSON object, a number, or null.
  final Object? data;

  Map<String, dynamic>? get json => data is Map ? Map<String, dynamic>.from(data! as Map) : null;
}

// The single connection to /hubs/realtime. Events are events, not data: a screen reacts to the ones it cares about
// by updating or refetching. Signing in opens the connection, signing out closes it.
class RealtimeService {
  RealtimeService(this._tokenReader);

  final Future<String?> Function() _tokenReader;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  HubConnection? _connection;

  Stream<RealtimeEvent> get events => _controller.stream;
  Stream<RealtimeEvent> on(String name) => events.where((e) => e.name == name);

  bool _wanted = false;

  // Opens the connection and, when the first start fails (slow network, server waking up), tries again with a growing
  // pause until it works or the user signs out. Drops after a successful start are handled by automatic reconnect.
  Future<void> connect() async {
    if (_wanted) return;
    _wanted = true;

    var pause = const Duration(seconds: 2);
    while (_wanted) {
      final connection = _build();
      _connection = connection;
      try {
        await connection.start();
        return;
      } on Object catch (e) {
        debugPrint('Realtime connection failed: $e');
        _connection = null;
        await connection.stop().catchError((_) {});
        await Future<void>.delayed(pause);
        if (pause < const Duration(seconds: 30)) pause *= 2;
      }
    }
  }

  HubConnection _build() {
    final connection = HubConnectionBuilder()
        .withUrl(
          '${AppConfig.apiBaseUrl}/hubs/realtime',
          options: HttpConnectionOptions(accessTokenFactory: () async => await _tokenReader() ?? ''),
        )
        .withAutomaticReconnect()
        .build();

    for (final name in RealtimeEvents.all) {
      connection.on(
        name,
        (arguments) => _controller.add(RealtimeEvent(name, arguments?.isNotEmpty == true ? arguments!.first : null)),
      );
    }
    connection.onreconnected(({connectionId}) => _controller.add(const RealtimeEvent(RealtimeEvents.reconnected)));
    return connection;
  }

  Future<void> disconnect() async {
    _wanted = false;
    final connection = _connection;
    _connection = null;
    await connection?.stop();
  }

  // Join or leave a group (WatchCourt, WatchPost, WatchTournament ...).
  Future<void> invoke(String method, List<Object> args) async {
    if (_connection?.state != HubConnectionState.Connected) return;
    await _connection!.invoke(method, args: args);
  }

  void dispose() {
    _controller.close();
    disconnect();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final store = ref.read(sessionStoreProvider);
  final service = RealtimeService(() async => (await store.read())?.token);
  ref.onDispose(service.dispose);
  return service;
});

// Keeps the connection in step with the session. Watched once, at the top of the app.
final realtimeLifecycleProvider = Provider<void>((ref) {
  final service = ref.read(realtimeServiceProvider);

  void apply(bool signedIn) => signedIn ? service.connect() : service.disconnect();

  ref.listen(authControllerProvider, (_, next) => apply(next.valueOrNull != null), fireImmediately: true);
});

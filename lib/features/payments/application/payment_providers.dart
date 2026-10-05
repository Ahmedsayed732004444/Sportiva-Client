import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/widgets/snack.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../owner/application/owner_controllers.dart';
import '../../tournaments/application/tournament_controllers.dart';
import '../data/payment_models.dart';
import '../data/payment_repository.dart';

final paymentMethodsProvider = FutureProvider<List<PayMethod>>((ref) => ref.read(paymentRepositoryProvider).methods());

// The payment the user just left the app to make: followed when they come back.
final pendingPaymentProvider = StateProvider<String?>((ref) => null);

// Tells the user how a payment ended, whichever way the news arrives first: the server pushing it, or the app
// asking when the user comes back from the payment page. Screens that show what was paid for refresh themselves.
final paymentFeedbackProvider = Provider<void>((ref) {
  final told = <String>{};

  void announce(String paymentId, PaymentOutcome outcome) {
    if (!outcome.isFinal || !told.add('$paymentId:${outcome.name}')) return;

    final l10n = lookupAppLocalizations(ref.read(localeProvider));
    showRootSnack(switch (outcome) {
      PaymentOutcome.succeeded => l10n.paymentSucceeded,
      PaymentOutcome.refunded => l10n.paymentRefunded,
      PaymentOutcome.expired => l10n.paymentExpired,
      _ => l10n.paymentFailed,
    });

    if (ref.read(pendingPaymentProvider) == paymentId) ref.read(pendingPaymentProvider.notifier).state = null;
    ref.invalidate(teamProvider);
    ref.invalidate(myTeamsProvider);
    ref.invalidate(tournamentProvider);
    ref.invalidate(ownerClubProvider);
  }

  final events = ref.read(realtimeServiceProvider).events.listen((event) {
    final json = event.json;
    if (event.name == RealtimeEvents.paymentChanged && json != null) {
      announce(json['paymentId'].toString(), PaymentOutcome.fromApi(json['status']));
    }
  });

  final lifecycle = AppLifecycleListener(
    onResume: () async {
      final id = ref.read(pendingPaymentProvider);
      if (id == null || ref.read(authControllerProvider).valueOrNull == null) return;
      try {
        announce(id, await ref.read(paymentRepositoryProvider).outcome(id));
      } on Object {
        // Not knowing yet is fine: the server's push or the next resume will tell.
      }
    },
  );

  ref.onDispose(() {
    events.cancel();
    lifecycle.dispose();
  });
});

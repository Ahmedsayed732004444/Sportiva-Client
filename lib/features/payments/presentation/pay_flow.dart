import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snack.dart';
import '../application/payment_providers.dart';
import '../data/payment_models.dart';

// The whole way to pay for something: pick how (only the ways the server offers), create the payment, open its page
// in the browser, and remember it so the app can tell the user how it ended when they come back.
Future<void> startPayment(
  BuildContext context,
  WidgetRef ref,
  Future<PaymentSession> Function(PayMethod method) create,
) async {
  final l10n = context.l10n;

  final List<PayMethod> methods;
  try {
    methods = await ref.read(paymentMethodsProvider.future);
  } on ApiException catch (e) {
    if (context.mounted) showApiError(context, e);
    return;
  }
  if (!context.mounted) return;
  if (methods.isEmpty) {
    showSnack(context, l10n.noPaymentMethods);
    return;
  }

  final method = methods.length == 1
      ? methods.single
      : await showModalBottomSheet<PayMethod>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final method in methods)
                  ListTile(
                    leading: Icon(method == PayMethod.card ? Icons.credit_card : Icons.account_balance_wallet_outlined),
                    title: Text(method == PayMethod.card ? l10n.payWithCard : l10n.payWithWallet),
                    onTap: () => Navigator.pop(context, method),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: Text(l10n.payHint, style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
        );
  if (method == null) return;

  try {
    final session = await create(method);
    ref.read(pendingPaymentProvider.notifier).state = session.paymentId;
    final opened = await launchUrl(Uri.parse(session.checkoutUrl), mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) showSnack(context, l10n.unknownError);
  } on ApiException catch (e) {
    if (context.mounted) showApiError(context, e);
  }
}

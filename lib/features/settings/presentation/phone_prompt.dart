import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/dispose_soon.dart';
import '../../../core/widgets/snack.dart';
import '../../auth/application/auth_controller.dart';
import '../application/account_providers.dart';
import '../data/account_repository.dart';

// Makes sure the account has a phone number (clubs call about bookings): asks for it when missing and saves it.
// Returns false when the person did not give one.
Future<bool> ensurePhone(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  // Signed out: the booking itself will ask to sign in.
  if (ref.read(authControllerProvider).valueOrNull == null) return true;

  final AccountProfile account;
  try {
    account = await ref.read(accountProvider.future).timeout(const Duration(seconds: 15));
  } on Object {
    return true;
  }
  if (account.phone?.trim().isNotEmpty ?? false) return true;
  if (!context.mounted) return false;

  final validators = Validators(l10n);
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.phoneNeededTitle),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.phoneNeededBody),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.phone,
              validator: validators.phone,
              decoration: InputDecoration(hintText: l10n.enterPhone),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.pop(dialog, true);
          },
          child: Text(l10n.savePhone),
        ),
      ],
    ),
  );
  final phone = controller.text.trim();
  disposeSoon(controller);
  if (saved != true) return false;

  try {
    await ref
        .read(accountRepositoryProvider)
        .updateProfile(firstName: account.firstName, lastName: account.lastName, phone: phone);
    ref.invalidate(accountProvider);
    return true;
  } on ApiException catch (e) {
    if (context.mounted) showApiError(context, e);
    return false;
  }
}

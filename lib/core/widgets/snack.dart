import 'package:flutter/material.dart';

import '../localization/l10n_extension.dart';
import '../network/api_exception.dart';

void showSnack(BuildContext context, String? message) {
  if (message == null) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// Tells the user why a request failed, if the screen is still there.
void showApiError(BuildContext context, ApiException error) {
  if (context.mounted) showSnack(context, error.messageFor(context.l10n) ?? context.l10n.unknownError);
}

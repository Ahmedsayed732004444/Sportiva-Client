import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/l10n_extension.dart';
import '../network/api_exception.dart';

// What every form screen does around a request: block double taps, show a spinner, and turn a failure into a snack bar.
mixin SubmitMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool isSubmitting = false;

  // Returns true when the action succeeded, so the caller can navigate. With rethrowErrors the caller handles the
  // ApiException itself (and shows its own message) instead of the default snack bar.
  Future<bool> submit(Future<void> Function() action, {bool rethrowErrors = false}) async {
    if (isSubmitting) return false;
    setState(() => isSubmitting = true);

    try {
      await action();
      return true;
    } on ApiException catch (e) {
      if (rethrowErrors) rethrow;
      if (mounted) showMessage(e.messageFor(context.l10n));
      return false;
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void showMessage(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

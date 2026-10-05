import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../data/account_repository.dart';

// The signed-in user's account (roles, phone, language). Refetched for another user.
final accountProvider = FutureProvider<AccountProfile>((ref) {
  ref.watch(authControllerProvider.select((session) => session.valueOrNull?.userId));
  return ref.read(accountRepositoryProvider).profile();
});

final managesClubProvider = Provider<bool>((ref) => ref.watch(accountProvider).valueOrNull?.managesClub ?? false);

// Keeps the language the server uses for emails and notifications equal to the app's.
final languageSyncProvider = Provider<void>((ref) {
  Future<void> push(String code) async {
    if (ref.read(authControllerProvider).valueOrNull == null) return;
    try {
      await ref.read(accountRepositoryProvider).setLanguage(code);
    } on Object {
      // Not worth bothering the user: it is tried again at the next change.
    }
  }

  ref.listen(localeProvider, (_, locale) => push(locale.languageCode));

  ref.listen(accountProvider, (_, account) {
    final server = account.valueOrNull?.languageCode;
    final local = ref.read(localeProvider).languageCode;
    if (server != null && server != local) push(local);
  });
});

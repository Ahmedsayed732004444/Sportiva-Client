import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/session_store.dart';
import '../data/auth_repository.dart';
import '../data/auth_session.dart';
import '../data/google_auth_service.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

// The signed-in session (null = signed out). Loading while the stored session is being read at startup.
class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    // A failed token refresh (see the API client) ends the session.
    ref.listen(sessionExpiredProvider, (_, _) => state = const AsyncData(null));
    return ref.read(sessionStoreProvider).read();
  }

  Future<void> signIn({required String email, required String password}) async =>
      _start(await ref.read(authRepositoryProvider).signIn(email: email, password: password));

  Future<void> signInWithGoogle() async {
    final idToken = await ref.read(googleAuthServiceProvider).getIdToken();
    await _start(await ref.read(authRepositoryProvider).signInWithGoogle(idToken));
  }

  Future<void> refreshSession() async {
    final session = state.valueOrNull;
    if (session == null) return;
    await _start(await ref.read(authRepositoryProvider).refresh(session));
  }

  Future<void> signOut() async {
    final session = state.valueOrNull;
    state = const AsyncData(null);
    await ref.read(sessionStoreProvider).clear();
    if (session != null) {
      try {
        await ref.read(authRepositoryProvider).revoke(session);
      } on Object {
        // The local session is already gone; the server copy expires by itself.
      }
    }
  }

  Future<void> _start(AuthSession session) async {
    await ref.read(sessionStoreProvider).save(session);
    state = AsyncData(session);
  }
}

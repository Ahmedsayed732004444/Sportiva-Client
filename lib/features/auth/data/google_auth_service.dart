import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) => GoogleAuthService());

class GoogleAuthService {
  bool _initialized = false;

  // Opens Google's account picker and returns the ID token the API verifies.
  Future<String> getIdToken() async {
    if (AppConfig.googleServerClientId.isEmpty) throw const ApiException.notConfigured();

    try {
      if (!_initialized) {
        await GoogleSignIn.instance.initialize(serverClientId: AppConfig.googleServerClientId);
        _initialized = true;
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const ApiException(kind: ApiErrorKind.unknown);
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const ApiException.cancelled();
      throw const ApiException(kind: ApiErrorKind.unknown);
    }
  }
}

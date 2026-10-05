import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

// Every call of the /auth endpoints. Failures surface as ApiException.
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  static final _public = Options(extra: noAuth);

  Future<AuthSession> signIn({required String email, required String password}) =>
      _session('/auth/login', {'email': email, 'password': password});

  // The ID token Google gave the app; the API checks it and signs the user in (creating the account on first use).
  Future<AuthSession> signInWithGoogle(String idToken) => _session('/auth/google', {'credential': idToken});

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) => _send('/auth/register', {'email': email, 'firstName': firstName, 'lastName': lastName, 'password': password});

  Future<void> confirmEmail({required String email, required String code}) =>
      _send('/auth/confirm-email', {'email': email, 'code': code});

  Future<void> resendConfirmation(String email) => _send('/auth/resend-confirmation-email', {'email': email});

  Future<void> forgotPassword(String email) => _send('/auth/forget-password', {'email': email});

  Future<void> resetPassword({required String email, required String code, required String newPassword}) =>
      _send('/auth/reset-password', {'email': email, 'code': code, 'newPassword': newPassword});

  // A fresh token pair: the roles inside the token follow the account as it is now.
  Future<AuthSession> refresh(AuthSession session) =>
      _session('/auth/refresh', {'token': session.token, 'refreshToken': session.refreshToken});

  Future<void> revoke(AuthSession session) =>
      _send('/auth/revoke-refresh-token', {'token': session.token, 'refreshToken': session.refreshToken});

  Future<AuthSession> _session(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body, options: _public);
      return AuthSession.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> _send(String path, Map<String, dynamic> body) async {
    try {
      await _dio.post<void>(path, data: body, options: _public);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

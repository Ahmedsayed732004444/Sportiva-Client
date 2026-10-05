import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_session.dart';
import '../config/app_config.dart';
import '../localization/locale_controller.dart';
import '../storage/session_store.dart';

// Calls that must not carry (or refresh) a token: sign in, register, codes.
const noAuth = {'noAuth': true};

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(_LanguageInterceptor(() => ref.read(localeProvider).languageCode));
  dio.interceptors.add(
    _AuthInterceptor(
      dio: dio,
      store: ref.read(sessionStoreProvider),
      onSessionExpired: () => ref.read(sessionExpiredProvider.notifier).state++,
    ),
  );
  return dio;
});

// Bumped when a refresh failed: the auth controller listens and signs the user out.
final sessionExpiredProvider = StateProvider<int>((ref) => 0);

class _LanguageInterceptor extends Interceptor {
  _LanguageInterceptor(this._languageCode);
  final String Function() _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageCode();
    handler.next(options);
  }
}

// Adds the access token, and on a 401 refreshes it once (requests wait in line so only one refresh runs) and retries.
class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor({required this.dio, required this.store, required this.onSessionExpired});

  final Dio dio;
  final SessionStore store;
  final void Function() onSessionExpired;

  bool _skip(RequestOptions options) => options.extra['noAuth'] == true;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_skip(options)) {
      final session = await store.read();
      if (session != null) options.headers['Authorization'] = 'Bearer ${session.token}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || _skip(request) || request.extra['retried'] == true) {
      return handler.next(err);
    }

    final session = await store.read();
    if (session == null) return handler.next(err);

    final refreshed = await _refresh(session, request.headers['Accept-Language']?.toString());
    if (refreshed == null) {
      await store.clear();
      onSessionExpired();
      return handler.next(err);
    }

    request.extra['retried'] = true;
    request.headers['Authorization'] = 'Bearer ${refreshed.token}';
    try {
      handler.resolve(await dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<AuthSession?> _refresh(AuthSession session, String? language) async {
    try {
      final plain = Dio(BaseOptions(baseUrl: dio.options.baseUrl, headers: {'Accept-Language': ?language}));
      final response = await plain.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'token': session.token, 'refreshToken': session.refreshToken},
      );
      final next = AuthSession.fromJson(response.data!);
      await store.save(next);
      return next;
    } on DioException {
      return null;
    }
  }
}

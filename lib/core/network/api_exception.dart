import 'package:dio/dio.dart';

import '../../l10n/app_localizations.dart';

enum ApiErrorKind { server, network, cancelled, notConfigured, unknown }

// One error type for every failed call. Server messages already come in the request language (Accept-Language).
class ApiException implements Exception {
  const ApiException({required this.kind, this.code, this.message, this.statusCode});

  const ApiException.cancelled() : this(kind: ApiErrorKind.cancelled);
  const ApiException.notConfigured() : this(kind: ApiErrorKind.notConfigured);

  final ApiErrorKind kind;
  final String? code;
  final String? message;
  final int? statusCode;

  // The business error codes of the API, e.g. User.EmailNotConfirmed.
  bool hasCode(String value) => code == value;

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(kind: ApiErrorKind.network);
    }

    final errors = response.data is Map ? (response.data as Map)['errors'] : null;
    // Business errors: ["Code", "message"]. Validation errors: { "Field": ["message"] }.
    if (errors is List && errors.isNotEmpty) {
      return ApiException(
        kind: ApiErrorKind.server,
        code: errors.first.toString(),
        message: errors.length > 1 ? errors[1].toString() : null,
        statusCode: response.statusCode,
      );
    }
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      return ApiException(
        kind: ApiErrorKind.server,
        code: 'Validation',
        message: first is List && first.isNotEmpty ? first.first.toString() : null,
        statusCode: response.statusCode,
      );
    }

    final detail = response.data is Map ? (response.data as Map)['detail']?.toString() : null;
    return ApiException(kind: ApiErrorKind.server, message: detail, statusCode: response.statusCode);
  }

  // Null when nothing should be shown (the user cancelled).
  String? messageFor(AppLocalizations l10n) => switch (kind) {
    ApiErrorKind.cancelled => null,
    ApiErrorKind.network => l10n.networkError,
    ApiErrorKind.notConfigured => l10n.googleNotConfigured,
    ApiErrorKind.server => message ?? l10n.unknownError,
    ApiErrorKind.unknown => l10n.unknownError,
  };
}

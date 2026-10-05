import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'payment_models.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepository(ref.watch(apiClientProvider)));

class PaymentRepository {
  PaymentRepository(this._dio);

  final Dio _dio;

  // The ways to pay that the server has set up.
  Future<List<PayMethod>> methods() => _call(() async {
    final data = (await _dio.get<Map<String, dynamic>>('/payments/methods')).data!;
    return (data['methods'] as List).map(PayMethod.fromApi).whereType<PayMethod>().toList();
  });

  // Asks the server how a payment ended (it asks Paymob itself when the webhook is late).
  Future<PaymentOutcome> outcome(String paymentId) => _call(
    () async =>
        PaymentOutcome.fromApi((await _dio.get<Map<String, dynamic>>('/payments/$paymentId/status')).data!['status']),
  );

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import 'recurring_models.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>(
  (ref) => RecurringRepository(ref.watch(apiClientProvider)),
);

class RecurringRepository {
  RecurringRepository(this._dio);

  final Dio _dio;

  Future<RecurringPreview> preview(RecurringRequest request) => _call(
    () async => RecurringPreview.fromJson(
      (await _dio.post<Map<String, dynamic>>('/bookings/recurring/preview', data: request.toJson())).data!,
    ),
  );

  Future<RecurringBooking> create(RecurringRequest request) => _call(
    () async => RecurringBooking.fromJson(
      (await _dio.post<Map<String, dynamic>>('/bookings/recurring', data: request.toJson())).data!,
    ),
  );

  // The player's weekly bookings come as one plain list (there are few), so the first page is everything.
  Future<PagedResult<RecurringBooking>> mine(int page) => _call(() async {
    if (page > 1) return const PagedResult(items: [], hasMore: false);
    final response = await _dio.get<List<dynamic>>('/bookings/recurring/my');
    return PagedResult(
      items: response.data!.cast<Map<String, dynamic>>().map(RecurringBooking.fromJson).toList(),
      hasMore: false,
    );
  });

  Future<void> cancel(String id) =>
      _call(() => _dio.post<void>('/bookings/recurring/$id/cancel', data: {'reason': null}));

  // ---- the club's side
  Future<PagedResult<RecurringBooking>> clubList(int page) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/clubs/me/recurring-bookings',
      queryParameters: {'pageNumber': page, 'pageSize': 10},
    );
    return PagedResult.fromJson(response.data!, RecurringBooking.fromJson);
  });

  Future<RecurringBooking> createManual(
    RecurringRequest request, {
    String? customerName,
    String? customerPhone,
    String? userEmail,
  }) => _call(
    () async => RecurringBooking.fromJson(
      (await _dio.post<Map<String, dynamic>>(
        '/clubs/me/recurring-bookings',
        data: {
          ...request.toJson(),
          'customerName': customerName,
          'customerPhone': customerPhone,
          'userEmail': userEmail,
        },
      )).data!,
    ),
  );

  Future<void> confirm(String id) => _call(() => _dio.post<void>('/clubs/me/recurring-bookings/$id/confirm'));
  Future<void> reject(String id, String? reason) =>
      _call(() => _dio.post<void>('/clubs/me/recurring-bookings/$id/reject', data: {'reason': reason}));
  Future<void> clubCancel(String id, String? reason) =>
      _call(() => _dio.post<void>('/clubs/me/recurring-bookings/$id/cancel', data: {'reason': reason}));

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

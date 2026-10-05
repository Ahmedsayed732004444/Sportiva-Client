import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import '../../booking/data/booking_models.dart';

final ownerBookingRepositoryProvider = Provider<OwnerBookingRepository>(
  (ref) => OwnerBookingRepository(ref.watch(apiClientProvider)),
);

enum OwnerBookingTab { pending, upcoming, past }

// The bookings of the owner's club, and what the club does with them.
class OwnerBookingRepository {
  OwnerBookingRepository(this._dio);

  final Dio _dio;

  Future<PagedResult<Booking>> list(OwnerBookingTab tab, {required int page, int pageSize = 10}) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/clubs/me/bookings',
      queryParameters: {
        'Filter': [
          if (tab == OwnerBookingTab.pending) 'status:eq:Pending',
          if (tab == OwnerBookingTab.upcoming) 'status:eq:Confirmed',
        ],
        'upcoming': tab != OwnerBookingTab.past,
        'pageNumber': page,
        'pageSize': pageSize,
      },
    );
    return PagedResult.fromJson(response.data!, Booking.fromJson);
  });

  Future<void> confirm(String id) => _call(() => _dio.post<void>('/clubs/me/bookings/$id/confirm'));
  Future<void> reject(String id, String? reason) =>
      _call(() => _dio.post<void>('/clubs/me/bookings/$id/reject', data: {'reason': reason}));
  Future<void> cancel(String id, String? reason) =>
      _call(() => _dio.post<void>('/clubs/me/bookings/$id/cancel', data: {'reason': reason}));
  Future<void> complete(String id) => _call(() => _dio.post<void>('/clubs/me/bookings/$id/complete'));
  Future<void> markNoShow(String id) => _call(() => _dio.post<void>('/clubs/me/bookings/$id/no-show'));

  Future<Booking> createManual({
    required String courtId,
    required DateTime day,
    required String startTime,
    required int durationMinutes,
    required CourtPart part,
    PlayFormat? playFormat,
    String? customerName,
    String? customerPhone,
    String? userEmail,
  }) => _call(
    () async => Booking.fromJson(
      (await _dio.post<Map<String, dynamic>>(
        '/clubs/me/bookings',
        data: {
          'courtId': courtId,
          'day': apiDay(day),
          'startTime': startTime,
          'durationMinutes': durationMinutes,
          'courtPart': part.apiName,
          'playFormat': playFormat?.apiName,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'userEmail': userEmail,
        },
      )).data!,
    ),
  );

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

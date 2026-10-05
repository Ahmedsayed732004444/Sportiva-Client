import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import 'booking_models.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository(ref.watch(apiClientProvider)));

class BookingRepository {
  BookingRepository(this._dio);

  final Dio _dio;

  Future<Booking> create({
    required String courtId,
    required DateTime day,
    required String startTime,
    required int durationMinutes,
    required CourtPart part,
    PlayFormat? playFormat,
  }) => _call(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/bookings',
      data: {
        'courtId': courtId,
        'day': apiDay(day),
        'startTime': startTime,
        'durationMinutes': durationMinutes,
        'courtPart': part.apiName,
        'playFormat': playFormat?.apiName,
      },
    );
    return Booking.fromJson(response.data!);
  });

  // Upcoming = not ended yet; otherwise the ones that already ended.
  Future<PagedResult<Booking>> mine({required bool upcoming, required int page, int pageSize = 10}) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/bookings/my',
      queryParameters: {'pageNumber': page, 'pageSize': pageSize, 'upcoming': upcoming},
    );
    return PagedResult.fromJson(response.data!, Booking.fromJson);
  });

  Future<Booking> get(String id) =>
      _call(() async => Booking.fromJson((await _dio.get<Map<String, dynamic>>('/bookings/$id')).data!));

  Future<void> cancel(String id, String? reason) =>
      _call(() => _dio.post<void>('/bookings/$id/cancel', data: {'reason': reason}));

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

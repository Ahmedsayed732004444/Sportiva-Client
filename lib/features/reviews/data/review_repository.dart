import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import 'review_models.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => ReviewRepository(ref.watch(apiClientProvider)));

class ReviewRepository {
  ReviewRepository(this._dio);

  final Dio _dio;

  Future<void> rateBooking(String bookingId, int rating, String? comment) =>
      _call(() => _dio.post<void>('/bookings/$bookingId/review', data: {'rating': rating, 'comment': comment}));

  // A club rates the player of one of its bookings.
  Future<void> rateBookingPlayer(String bookingId, int rating, String? comment) => _call(
    () => _dio.post<void>('/clubs/me/bookings/$bookingId/player-review', data: {'rating': rating, 'comment': comment}),
  );

  Future<void> rateMatchPlayer(String matchId, String playerId, int rating, String? comment) => _call(
    () => _dio.post<void>(
      '/matches/$matchId/reviews',
      data: {'playerId': playerId, 'rating': rating, 'comment': comment},
    ),
  );

  Future<void> rateTournamentPlayer(String matchId, String playerId, int rating, String? comment) => _call(
    () => _dio.post<void>(
      '/tournament-matches/$matchId/reviews',
      data: {'playerId': playerId, 'rating': rating, 'comment': comment},
    ),
  );

  Future<PagedResult<MyReview>> written(int page) => _page('/reviews/written', page);
  Future<PagedResult<MyReview>> received(int page) => _page('/reviews/received', page);

  Future<void> update(String id, int rating, String? comment) =>
      _call(() => _dio.put<void>('/reviews/$id', data: {'rating': rating, 'comment': comment}));
  Future<void> delete(String id) => _call(() => _dio.delete<void>('/reviews/$id'));

  Future<PagedResult<MyReview>> _page(String path, int page) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: {'pageNumber': page, 'pageSize': 15});
    return PagedResult.fromJson(response.data!, MyReview.fromJson);
  });

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import '../../catalog/data/sport_type.dart';
import 'match_models.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) => MatchRepository(ref.watch(apiClientProvider)));

class MatchRepository {
  MatchRepository(this._dio);

  final Dio _dio;

  Future<PagedResult<FriendlyMatch>> open({SportType? sport, required int page, int pageSize = 10}) =>
      _list('/matches', {
        if (sport != null) 'Filter': ['sportType:eq:${sport.apiName}'],
        'pageNumber': page,
        'pageSize': pageSize,
      });

  // role: "organizer" = matches I organize, "player" = matches I asked to join, null = both.
  Future<PagedResult<FriendlyMatch>> mine({String? role, bool? upcoming, required int page, int pageSize = 10}) =>
      _list('/matches/my', {'role': ?role, 'upcoming': ?upcoming, 'pageNumber': page, 'pageSize': pageSize});

  Future<FriendlyMatch> get(String id) =>
      _call(() async => FriendlyMatch.fromJson((await _dio.get<Map<String, dynamic>>('/matches/$id')).data!));

  // A match at an outside place (court matches are opened from a booking).
  Future<FriendlyMatch> createOutside({
    required SportType sport,
    required DateTime day,
    required String startTime,
    required int durationMinutes,
    required int playersNeeded,
    required String placeName,
    required String address,
    required int governorateId,
    required String city,
    String? note,
  }) => _call(
    () async => FriendlyMatch.fromJson(
      (await _dio.post<Map<String, dynamic>>(
        '/matches',
        data: {
          'sportType': sport.apiName,
          'day': apiDay(day),
          'startTime': startTime,
          'durationMinutes': durationMinutes,
          'playersNeeded': playersNeeded,
          'placeName': placeName,
          'address': address,
          'governorateId': governorateId,
          'city': city,
          'note': note,
        },
      )).data!,
    ),
  );

  // Opens the free places of a booking the player already has.
  Future<FriendlyMatch> openFromBooking(String bookingId, {required int playersNeeded, String? note}) => _call(
    () async => FriendlyMatch.fromJson(
      (await _dio.post<Map<String, dynamic>>(
        '/bookings/$bookingId/open-match',
        data: {'playersNeeded': playersNeeded, 'note': note},
      )).data!,
    ),
  );

  Future<void> requestToJoin(String matchId) => _call(() => _dio.post<void>('/matches/$matchId/join-requests'));

  Future<void> leave(String matchId) => _call(() => _dio.post<void>('/matches/$matchId/leave'));

  Future<void> cancel(String matchId, String? reason) =>
      _call(() => _dio.post<void>('/matches/$matchId/cancel', data: {'reason': reason}));

  Future<List<JoinRequest>> joinRequests(String matchId) => _call(() async {
    final response = await _dio.get<List<dynamic>>('/matches/$matchId/join-requests');
    return response.data!.cast<Map<String, dynamic>>().map(JoinRequest.fromJson).toList();
  });

  Future<void> accept(String matchId, String requestId) =>
      _call(() => _dio.post<void>('/matches/$matchId/join-requests/$requestId/accept'));

  Future<void> reject(String matchId, String requestId) =>
      _call(() => _dio.post<void>('/matches/$matchId/join-requests/$requestId/reject'));

  Future<PagedResult<FriendlyMatch>> _list(String path, Map<String, dynamic> query) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
    return PagedResult.fromJson(response.data!, FriendlyMatch.fromJson);
  });

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

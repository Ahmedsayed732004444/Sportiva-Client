import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/coordinates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import 'catalog_models.dart';
import '../../booking/data/booking_models.dart';
import '../../../core/localization/date_time_format.dart';
import '../../matches/data/match_models.dart';
import 'sport_type.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiClientProvider)));

// The public lists of the platform: courts and clubs. [at] makes the API return distances and sort by nearest.
class CatalogRepository {
  CatalogRepository(this._dio);

  final Dio _dio;

  Future<PagedResult<CourtListItem>> courts({
    required SportType sport,
    Coordinates? at,
    int page = 1,
    int pageSize = 10,
  }) => _list('/courts', CourtListItem.fromJson, {
    'pageNumber': page,
    'pageSize': pageSize,
    'Filter': ['sportType:eq:${sport.apiName}'],
    ..._location(at),
  });

  // topRated sorts by rating (then by reviews) instead of distance.
  Future<PagedResult<ClubListItem>> clubs({Coordinates? at, bool topRated = false, int page = 1, int pageSize = 10}) =>
      _list('/clubs', ClubListItem.fromJson, {
        'pageNumber': page,
        'pageSize': pageSize,
        if (topRated) 'topRated': true,
        ..._location(at),
      });

  Future<ClubDetails> club(String id) => _get('/clubs/$id', ClubDetails.fromJson);

  Future<List<CourtListItem>> courtsOfClub(String clubId) async => (await _list('/courts', CourtListItem.fromJson, {
    'pageNumber': 1,
    'pageSize': 50,
    'Filter': ['clubId:eq:$clubId'],
  })).items;

  Future<CourtDetails> court(String id) => _get('/courts/$id', CourtDetails.fromJson);

  Future<List<SlotUnit>> availability(String courtId, DateTime day) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/courts/$courtId/availability',
      queryParameters: {'day': apiDay(day)},
      options: Options(extra: noAuth),
    );
    return (response.data!['units'] as List).cast<Map<String, dynamic>>().map(SlotUnit.fromJson).toList();
  });

  Future<List<ReviewItem>> clubReviews(String clubId, {int pageSize = 5}) async =>
      (await _list('/clubs/$clubId/reviews', ReviewItem.fromJson, {'pageNumber': 1, 'pageSize': pageSize})).items;

  Future<List<Governorate>> governorates() => _call(() async {
    final response = await _dio.get<List<dynamic>>('/governorates', options: Options(extra: noAuth));
    return response.data!.cast<Map<String, dynamic>>().map(Governorate.fromJson).toList();
  });

  Future<T> _get<T>(String path, T Function(Map<String, dynamic>) parse) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(path, options: Options(extra: noAuth));
    return parse(response.data!);
  });

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _location(Coordinates? at) => at == null ? const {} : {'lat': at.latitude, 'lng': at.longitude};

  Future<PagedResult<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: Options(extra: noAuth),
      );
      return PagedResult.fromJson(response.data!, parse);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

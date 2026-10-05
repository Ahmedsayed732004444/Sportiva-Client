import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import '../../tournaments/data/tournament_models.dart';
import '../../../core/localization/date_time_format.dart';
import 'owner_club_models.dart';
import 'report_models.dart';

final ownerClubRepositoryProvider = Provider<OwnerClubRepository>(
  (ref) => OwnerClubRepository(ref.watch(apiClientProvider)),
);

class OwnerClubRepository {
  OwnerClubRepository(this._dio);

  final Dio _dio;

  Future<OwnerClub> club() =>
      _call(() async => OwnerClub.fromJson((await _dio.get<Map<String, dynamic>>('/clubs/me')).data!));

  Future<void> update({
    required String name,
    required int governorateId,
    required String city,
    required String address,
    required String phone,
    String? mapUrl,
    String? email,
  }) => _call(
    () => _dio.put<void>(
      '/clubs/me',
      data: {
        'name': name,
        'governorateId': governorateId,
        'city': city,
        'address': address,
        'mapUrl': mapUrl,
        'phone': phone,
        'email': email,
      },
    ),
  );

  Future<void> toggleStatus() => _call(() => _dio.patch<void>('/clubs/me/status'));

  // Seven days, each once: DayOfWeek 0 (Sunday) to 6.
  Future<void> setWorkingHours(List<({int day, bool closed, String opens, String closes})> days) => _call(
    () => _dio.put<void>(
      '/clubs/me/working-hours',
      data: {
        'days': [
          for (final d in days) {'dayOfWeek': d.day, 'isClosed': d.closed, 'opensAt': d.opens, 'closesAt': d.closes},
        ],
      },
    ),
  );

  Future<void> setLogo(String path) => _upload('/clubs/me/logo', path);
  Future<void> setCover(String path) => _upload('/clubs/me/cover', path);

  Future<void> _upload(String url, String path) =>
      _call(() async => _dio.put<void>(url, data: FormData.fromMap({'file': await MultipartFile.fromFile(path)})));

  Future<void> addImages(List<String> paths) => _call(
    () async => _dio.post<void>(
      '/clubs/me/images',
      data: FormData.fromMap({
        'Images': [for (final path in paths) await MultipartFile.fromFile(path)],
      }),
    ),
  );

  Future<void> deleteImage(String imageId) => _call(() => _dio.delete<void>('/clubs/me/images/$imageId'));

  Future<ClubReport> report({required DateTime from, required DateTime to}) => _call(
    () async => ClubReport.fromJson(
      (await _dio.get<Map<String, dynamic>>(
        '/clubs/me/reports',
        queryParameters: {'from': apiDay(from), 'to': apiDay(to)},
      )).data!,
    ),
  );

  Future<List<Plan>> plans() => _call(() async {
    final response = await _dio.get<List<dynamic>>('/subscription-plans', options: Options(extra: noAuth));
    return response.data!.cast<Map<String, dynamic>>().map(Plan.fromJson).toList();
  });

  // The page where the subscription is paid (opened in the browser).
  Future<String> subscribe(String planId, PayMethod method) => _call(
    () async =>
        (await _dio.post<Map<String, dynamic>>(
              '/clubs/me/subscriptions',
              data: {'planId': planId, 'method': method.apiName},
            )).data!['checkoutUrl']
            as String,
  );

  Future<String> renew(PayMethod method) => _call(
    () async =>
        (await _dio.post<Map<String, dynamic>>(
              '/clubs/me/subscriptions/renew',
              data: {'method': method.apiName},
            )).data!['checkoutUrl']
            as String,
  );

  Future<List<StaffMember>> staff() => _call(() async {
    final data = (await _dio.get<Map<String, dynamic>>('/clubs/me/staff')).data!;
    return (data['staff'] as List).cast<Map<String, dynamic>>().map(StaffMember.fromJson).toList();
  });

  Future<void> addStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required List<StaffPermission> permissions,
    String? phone,
    List<String> courtIds = const [],
  }) => _call(
    () => _dio.post<void>(
      '/clubs/me/staff',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phone,
        'permissions': [for (final p in permissions) p.apiName],
        'courtIds': courtIds,
      },
    ),
  );

  Future<void> toggleStaff(String id) => _call(() => _dio.patch<void>('/clubs/me/staff/$id/status'));
  Future<void> removeStaff(String id) => _call(() => _dio.delete<void>('/clubs/me/staff/$id'));
  Future<void> resetStaffPassword(String id, String password) =>
      _call(() => _dio.put<void>('/clubs/me/staff/$id/password', data: {'newPassword': password}));

  Future<PagedResult<ActivityEntry>> activity(int page) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/clubs/me/activity',
      queryParameters: {'pageNumber': page, 'pageSize': 20},
    );
    return PagedResult.fromJson(response.data!, ActivityEntry.fromJson);
  });

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

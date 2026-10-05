import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'membership_models.dart';

final membershipRepositoryProvider = Provider<MembershipRepository>(
  (ref) => MembershipRepository(ref.watch(apiClientProvider)),
);

class MembershipRepository {
  MembershipRepository(this._dio);

  final Dio _dio;

  // The user's latest request, or null when they never sent one.
  Future<MembershipRequest?> mine() async {
    try {
      return MembershipRequest.fromJson((await _dio.get<Map<String, dynamic>>('/membership-requests/me')).data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDio(e);
    }
  }

  // Photos and videos travel with the request; videos are prepared in the background afterwards.
  Future<MembershipRequest> create({
    required String fullName,
    required String phone,
    required String clubName,
    required int governorateId,
    required String city,
    required String address,
    String? locationUrl,
    String? note,
    List<String> imagePaths = const [],
    List<String> videoPaths = const [],
  }) => _call(() async {
    final form = FormData.fromMap({
      'FullName': fullName,
      'Phone': phone,
      'ClubName': clubName,
      'GovernorateId': governorateId,
      'City': city,
      'Address': address,
      'LocationUrl': ?locationUrl,
      'Note': ?note,
      if (imagePaths.isNotEmpty) 'Images': [for (final path in imagePaths) await MultipartFile.fromFile(path)],
      if (videoPaths.isNotEmpty) 'Videos': [for (final path in videoPaths) await MultipartFile.fromFile(path)],
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/membership-requests',
      data: form,
      options: Options(sendTimeout: const Duration(minutes: 15)),
    );
    return MembershipRequest.fromJson(response.data!);
  });

  Future<MembershipRequest> addMedia(
    String id, {
    List<String> imagePaths = const [],
    List<String> videoPaths = const [],
  }) => _call(() async {
    final form = FormData.fromMap({
      if (imagePaths.isNotEmpty) 'Images': [for (final path in imagePaths) await MultipartFile.fromFile(path)],
      if (videoPaths.isNotEmpty) 'Videos': [for (final path in videoPaths) await MultipartFile.fromFile(path)],
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/membership-requests/$id/media',
      data: form,
      options: Options(sendTimeout: const Duration(minutes: 15)),
    );
    return MembershipRequest.fromJson(response.data!);
  });

  Future<void> deleteMedia(String id, String mediaId) =>
      _call(() => _dio.delete<void>('/membership-requests/$id/media/$mediaId'));

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

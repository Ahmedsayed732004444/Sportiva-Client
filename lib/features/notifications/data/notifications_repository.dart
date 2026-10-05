import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import 'app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  static const pageSize = 20;

  Future<PagedResult<AppNotification>> list(int page) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(response.data!, AppNotification.fromJson);
  });

  Future<int> unreadCount() => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    return response.data!['count'] as int;
  });

  Future<void> markRead(String id) => _call(() => _dio.put<void>('/notifications/$id/read'));

  Future<void> markAllRead() => _call(() => _dio.put<void>('/notifications/read-all'));

  Future<void> delete(String id) => _call(() => _dio.delete<void>('/notifications/$id'));

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

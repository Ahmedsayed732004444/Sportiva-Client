import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import 'chat_models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository(ref.watch(apiClientProvider)));

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  String _path(ChatTarget target) => target.isMatch ? '/messages/matches/${target.id}' : '/messages/with/${target.id}';

  // Newest first.
  Future<PagedResult<ChatMessage>> messages(ChatTarget target, {required int page, int pageSize = 30}) =>
      _call(() async {
        final response = await _dio.get<Map<String, dynamic>>(
          _path(target),
          queryParameters: {'pageNumber': page, 'pageSize': pageSize},
        );
        return PagedResult.fromJson(response.data!, ChatMessage.fromJson);
      });

  Future<ChatMessage> send(ChatTarget target, String text) => _call(
    () async =>
        ChatMessage.fromJson((await _dio.post<Map<String, dynamic>>(_path(target), data: {'text': text})).data!),
  );

  Future<ChatMessage> sendVoice(ChatTarget target, String path, int seconds) => _call(() async {
    final form = FormData.fromMap({
      'File': await MultipartFile.fromFile(path, filename: 'voice.m4a'),
      'Seconds': seconds,
    });
    return ChatMessage.fromJson((await _dio.post<Map<String, dynamic>>('${_path(target)}/voice', data: form)).data!);
  });

  Future<void> markRead(String userId) => _call(() => _dio.post<void>('/messages/with/$userId/read'));

  Future<int> unreadCount() => _call(
    () async => ((await _dio.get<Map<String, dynamic>>('/messages/unread-count')).data!['count'] as num).toInt(),
  );

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

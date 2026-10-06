import 'player_traits.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import '../../catalog/data/sport_type.dart';
import 'social_models.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) => SocialRepository(ref.watch(apiClientProvider)));

class SocialRepository {
  SocialRepository(this._dio);

  final Dio _dio;

  // ---- posts
  Future<PagedResult<Post>> feed(int page) => _page('/posts/feed', Post.fromJson, page);
  Future<PagedResult<Post>> explore(int page) => _page('/posts/explore', Post.fromJson, page);
  Future<PagedResult<Post>> reels(int page) => _page('/posts/reels', Post.fromJson, page, size: 6);
  Future<PagedResult<Post>> exploreSized(int page, int size) =>
      _page('/posts/explore', Post.fromJson, page, size: size);
  Future<PagedResult<Post>> saved(int page) => _page('/posts/saved', Post.fromJson, page);
  Future<PagedResult<Post>> userPosts(String userId, int page) => _page('/profiles/$userId/posts', Post.fromJson, page);

  Future<Post> post(String id) =>
      _call(() async => Post.fromJson((await _dio.get<Map<String, dynamic>>('/posts/$id')).data!));

  // Photos and a video go as multipart; the API answers at once and finishes the pictures and the video in the background.
  Future<Post> createPost({String? text, List<String> imagePaths = const [], String? videoPath}) => _call(() async {
    final form = FormData.fromMap({
      if (text != null && text.trim().isNotEmpty) 'Text': text.trim(),
      if (imagePaths.isNotEmpty) 'Images': [for (final path in imagePaths) await MultipartFile.fromFile(path)],
      if (videoPath != null) 'Video': await MultipartFile.fromFile(videoPath),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/posts',
      data: form,
      options: Options(sendTimeout: const Duration(minutes: 10)),
    );
    return Post.fromJson(response.data!);
  });

  Future<void> editPost(String id, String? text) => _call(() => _dio.put<void>('/posts/$id', data: {'text': text}));
  Future<void> deletePost(String id) => _call(() => _dio.delete<void>('/posts/$id'));

  Future<({bool isLiked, int likesCount})> toggleLike(String postId) => _call(() async {
    final data = (await _dio.post<Map<String, dynamic>>('/posts/$postId/like')).data!;
    return (isLiked: data['isLiked'] as bool, likesCount: data['likesCount'] as int);
  });

  Future<({bool isSaved, int savesCount})> toggleSave(String postId) => _call(() async {
    final data = (await _dio.post<Map<String, dynamic>>('/posts/$postId/save')).data!;
    return (isSaved: data['isSaved'] as bool, savesCount: data['savesCount'] as int);
  });

  Future<void> recordView(String postId, {required int watchedSeconds, required bool completed}) => _call(
    () => _dio.post<void>(
      '/posts/$postId/views',
      data: {'watchedSeconds': watchedSeconds, 'completed': completed},
      options: Options(extra: noAuth),
    ),
  );

  Future<SearchResults> search(String text) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/explore/search',
      queryParameters: {'q': text},
      options: Options(extra: noAuth),
    );
    return SearchResults.fromJson(response.data!);
  });

  // ---- comments
  Future<PagedResult<Comment>> comments(String postId, int page) =>
      _page('/posts/$postId/comments', Comment.fromJson, page, size: 15);
  Future<PagedResult<Comment>> replies(String commentId, int page) =>
      _page('/comments/$commentId/replies', Comment.fromJson, page, size: 15);

  Future<Comment> addComment(String postId, String text, {String? replyToCommentId}) => _call(
    () async => Comment.fromJson(
      (await _dio.post<Map<String, dynamic>>(
        '/posts/$postId/comments',
        data: {'text': text, 'replyToCommentId': replyToCommentId},
      )).data!,
    ),
  );

  Future<void> deleteComment(String id) => _call(() => _dio.delete<void>('/comments/$id'));

  Future<({bool isLiked, int likesCount})> toggleCommentLike(String id) => _call(() async {
    final data = (await _dio.post<Map<String, dynamic>>('/comments/$id/like')).data!;
    return (isLiked: data['isLiked'] as bool, likesCount: data['likesCount'] as int);
  });

  // ---- profiles
  Future<UserProfile> profile(String userId) =>
      _call(() async => UserProfile.fromJson((await _dio.get<Map<String, dynamic>>('/profiles/$userId')).data!));

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required List<SportType> preferredSports,
    String? bio,
    String? city,
    int? governorateId,
    PlayerPosition? position,
    PreferredFoot? foot,
  }) => _call(
    () => _dio.put<void>(
      '/profiles/me',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'city': city,
        'governorateId': governorateId,
        'preferredSports': [for (final sport in preferredSports) sport.apiName],
        'position': position?.apiName,
        'preferredFoot': foot?.apiName,
      },
    ),
  );

  Future<void> setAvatar(String path) => _call(
    () async =>
        _dio.put<void>('/profiles/me/avatar', data: FormData.fromMap({'file': await MultipartFile.fromFile(path)})),
  );

  Future<({bool isFollowing, int followersCount})> toggleFollow(String userId) => _call(() async {
    final data = (await _dio.post<Map<String, dynamic>>('/profiles/$userId/follow')).data!;
    return (isFollowing: data['isFollowing'] as bool, followersCount: data['followersCount'] as int);
  });

  Future<PagedResult<FollowItem>> followers(String userId, int page) =>
      _page('/profiles/$userId/followers', FollowItem.fromJson, page, size: 20);
  Future<PagedResult<FollowItem>> following(String userId, int page) =>
      _page('/profiles/$userId/following', FollowItem.fromJson, page, size: 20);

  Future<void> block(String userId) => _call(() => _dio.post<void>('/profiles/$userId/block'));
  Future<void> unblock(String userId) => _call(() => _dio.delete<void>('/profiles/$userId/block'));

  Future<void> report({
    required String targetType,
    required String targetId,
    required ReportReason reason,
    String? note,
  }) => _call(
    () => _dio.post<void>(
      '/content-reports',
      data: {'targetType': targetType, 'targetId': targetId, 'reason': reason.apiName, 'note': note},
    ),
  );

  // ---- conversations
  Future<PagedResult<Conversation>> conversations(int page) =>
      _page('/messages/conversations', Conversation.fromJson, page, size: 20);

  Future<PagedResult<T>> _page<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
    int page, {
    int size = 10,
    bool auth = true,
  }) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'pageNumber': page, 'pageSize': size},
      options: auth ? null : Options(extra: noAuth),
    );
    return PagedResult.fromJson(response.data!, parse);
  });

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

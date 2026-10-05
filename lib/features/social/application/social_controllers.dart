import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

// A list that refetches when the connection comes back.
mixin _RefreshOnReconnect on PagedController<Post> {
  void refreshOnReconnect() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.reconnected) refresh();
    });
    ref.onDispose(subscription.cancel);
  }
}

// How many posts were published by people you follow since the feed was loaded.
class NewPostsCount extends AutoDisposeNotifier<int> {
  @override
  int build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.newPost) state++;
    });
    ref.onDispose(subscription.cancel);
    return 0;
  }

  void clear() => state = 0;
}

final newPostsCountProvider = AutoDisposeNotifierProvider<NewPostsCount, int>(NewPostsCount.new);

class FeedController extends PagedController<Post> with _RefreshOnReconnect {
  @override
  PagedState<Post> build() {
    refreshOnReconnect();
    return super.build();
  }

  @override
  Future<PagedResult<Post>> fetch(int page) => ref.read(socialRepositoryProvider).feed(page);

  @override
  Future<void> refresh() {
    ref.read(newPostsCountProvider.notifier).clear();
    return super.refresh();
  }
}

class ExploreController extends PagedController<Post> with _RefreshOnReconnect {
  @override
  PagedState<Post> build() {
    refreshOnReconnect();
    return super.build();
  }

  @override
  Future<PagedResult<Post>> fetch(int page) => ref.read(socialRepositoryProvider).explore(page);
}

class ReelsController extends PagedController<Post> {
  @override
  Future<PagedResult<Post>> fetch(int page) => ref.read(socialRepositoryProvider).reels(page);
}

class UserPostsController extends PagedFamilyController<Post, String> {
  @override
  Future<PagedResult<Post>> fetch(int page) => ref.read(socialRepositoryProvider).userPosts(arg, page);
}

class CommentsController extends PagedFamilyController<Comment, String> {
  @override
  PagedState<Comment> build(String arg) {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      final json = event.json;
      if (event.name == RealtimeEvents.reconnected) {
        refresh();
      } else if (event.name == RealtimeEvents.commentChanged && json?['postId'] == arg) {
        _apply(json!);
      }
    });
    ref.onDispose(subscription.cancel);
    return super.build(arg);
  }

  // Likes and reply counts update in place; a top-level comment added or removed is a refetch. (A reply being
  // added or removed is followed by an "updated" for its parent, which carries the new reply count.)
  void _apply(Map<String, dynamic> change) {
    final id = change['commentId'] as String;

    switch (change['change'].toString()) {
      case 'liked' || 'updated':
        replaceWhere(
          (c) => c.id == id,
          (c) => c.copyWith(likesCount: change['likesCount'] as int?, repliesCount: change['repliesCount'] as int?),
        );
      case 'added' || 'deleted' when change['parentId'] == null:
        refresh();
    }
  }

  @override
  Future<PagedResult<Comment>> fetch(int page) => ref.read(socialRepositoryProvider).comments(arg, page);

  void add(Comment comment) => prepend(comment);
}

class RepliesController extends PagedFamilyController<Comment, String> {
  @override
  Future<PagedResult<Comment>> fetch(int page) => ref.read(socialRepositoryProvider).replies(arg, page);
}

class FollowListController extends PagedFamilyController<FollowItem, ({String userId, bool followers})> {
  @override
  Future<PagedResult<FollowItem>> fetch(int page) {
    final repository = ref.read(socialRepositoryProvider);
    return arg.followers ? repository.followers(arg.userId, page) : repository.following(arg.userId, page);
  }
}

class ConversationsController extends PagedController<Conversation> {
  @override
  PagedState<Conversation> build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      const names = {RealtimeEvents.messageReceived, RealtimeEvents.messagesRead, RealtimeEvents.reconnected};
      if (names.contains(event.name)) refresh();
    });
    ref.onDispose(subscription.cancel);
    return super.build();
  }

  @override
  Future<PagedResult<Conversation>> fetch(int page) => ref.read(socialRepositoryProvider).conversations(page);
}

final feedProvider = AutoDisposeNotifierProvider<FeedController, PagedState<Post>>(FeedController.new);
final exploreProvider = AutoDisposeNotifierProvider<ExploreController, PagedState<Post>>(ExploreController.new);
final reelsProvider = AutoDisposeNotifierProvider<ReelsController, PagedState<Post>>(ReelsController.new);
final userPostsProvider = AutoDisposeNotifierProviderFamily<UserPostsController, PagedState<Post>, String>(
  UserPostsController.new,
);
final commentsProvider = AutoDisposeNotifierProviderFamily<CommentsController, PagedState<Comment>, String>(
  CommentsController.new,
);
final repliesProvider = AutoDisposeNotifierProviderFamily<RepliesController, PagedState<Comment>, String>(
  RepliesController.new,
);
final followListProvider =
    AutoDisposeNotifierProviderFamily<FollowListController, PagedState<FollowItem>, ({String userId, bool followers})>(
      FollowListController.new,
    );
final conversationsProvider = AutoDisposeNotifierProvider<ConversationsController, PagedState<Conversation>>(
  ConversationsController.new,
);

final postProvider = FutureProvider.autoDispose.family<Post, String>((ref, id) {
  final realtime = ref.read(realtimeServiceProvider);
  realtime.invoke('WatchPost', [id]);
  ref.onDispose(() => realtime.invoke('UnwatchPost', [id]));
  return ref.read(socialRepositoryProvider).post(id);
});

final profileProvider = FutureProvider.autoDispose.family<UserProfile, String>((ref, userId) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final same = event.name == RealtimeEvents.profileChanged && event.json?['userId'] == userId;
    if (same || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  final realtime = ref.read(realtimeServiceProvider);
  realtime.invoke('WatchProfile', [userId]);
  ref.onDispose(() => realtime.invoke('UnwatchProfile', [userId]));

  return ref.read(socialRepositoryProvider).profile(userId);
});

final searchTextProvider = StateProvider.autoDispose<String>((ref) => '');

final searchProvider = FutureProvider.autoDispose<SearchResults?>((ref) async {
  final text = ref.watch(searchTextProvider).trim();
  if (text.length < 2) return null;

  // Waits for a pause in typing: a request per keystroke would be wasteful.
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 400));
  if (cancelled) throw StateError('superseded');

  return ref.read(socialRepositoryProvider).search(text);
});

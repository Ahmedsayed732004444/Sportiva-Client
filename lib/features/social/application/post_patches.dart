import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/realtime/realtime_service.dart';
import '../data/social_models.dart';

// What changed on posts after they were loaded: likes you did, counts the server pushed, deletions.
// Every post card shows its loaded post with its patch on top, so a like is reflected everywhere the post appears.
class PostPatches extends Notifier<Map<String, PostPatch>> {
  @override
  Map<String, PostPatch> build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      final json = event.json;
      if (event.name != RealtimeEvents.postChanged || json == null) return;
      patch(
        json['postId'] as String,
        PostPatch(
          likesCount: json['likesCount'] as int?,
          commentsCount: json['commentsCount'] as int?,
          viewsCount: json['viewsCount'] as int?,
          isDeleted: json['isDeleted'] as bool? ?? false,
        ),
      );
    });
    ref.onDispose(subscription.cancel);
    return const {};
  }

  void patch(String postId, PostPatch change) =>
      state = {...state, postId: (state[postId] ?? const PostPatch()).merge(change)};
}

final postPatchesProvider = NotifierProvider<PostPatches, Map<String, PostPatch>>(PostPatches.new);

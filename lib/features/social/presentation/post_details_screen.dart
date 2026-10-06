import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/state_views.dart';
import '../application/social_controllers.dart';
import 'widgets/comments_panel.dart';
import 'widgets/post_card.dart';

class PostDetailsScreen extends ConsumerWidget {
  const PostDetailsScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(postId));

    return Scaffold(
      appBar: AppBar(),
      body: post.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(postProvider(postId)),
        ),
        data: (post) => CommentsPanel(
          postId: postId,
          header: PostCard(post: post, detailed: true),
        ),
      ),
    );
  }
}

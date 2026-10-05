import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';
import 'report_sheet.dart';
import 'widgets/post_card.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  const PostDetailsScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> with SubmitMixin {
  final _text = TextEditingController();
  Comment? _replyingTo;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;

    final target = _replyingTo;
    final done = await submit(() async {
      final comment = await ref
          .read(socialRepositoryProvider)
          .addComment(widget.postId, text, replyToCommentId: target?.id);
      if (target == null) {
        ref.read(commentsProvider(widget.postId).notifier).add(comment);
      } else {
        ref.invalidate(repliesProvider(target.parentId ?? target.id));
        ref
            .read(commentsProvider(widget.postId).notifier)
            .replaceWhere(
              (c) => c.id == (target.parentId ?? target.id),
              (c) => c.copyWith(repliesCount: c.repliesCount + 1),
            );
      }
    });

    if (done) {
      _text.clear();
      setState(() => _replyingTo = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final post = ref.watch(postProvider(widget.postId));
    final comments = ref.watch(commentsProvider(widget.postId));
    final controller = ref.read(commentsProvider(widget.postId).notifier);

    return Scaffold(
      appBar: AppBar(),
      body: post.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(postProvider(widget.postId)),
        ),
        data: (post) => Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.metrics.extentAfter < 300) controller.loadMore();
                  return false;
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  children: [
                    PostCard(post: post, detailed: true),
                    const SizedBox(height: AppSpacing.m),
                    Text(l10n.comments, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                    if (comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Center(child: Text(l10n.noComments, style: AppTextStyles.body2)),
                      ),
                    for (final comment in comments.items)
                      _CommentTile(
                        comment: comment,
                        postId: widget.postId,
                        onReply: (target) => setState(() => _replyingTo = target),
                      ),
                    if (comments.isLoading) const Padding(padding: EdgeInsets.all(AppSpacing.s), child: LoadingView()),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyingTo != null)
                    ListTile(
                      dense: true,
                      title: Text(l10n.replyingTo(_replyingTo!.author.fullName), style: AppTextStyles.body2),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _replyingTo = null),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            style: AppTextStyles.body1,
                            decoration: InputDecoration(hintText: l10n.writeComment),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton.filled(
                          onPressed: isSubmitting ? null : _send,
                          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                          icon: const Icon(Icons.send_rounded, color: AppColors.white),
                          tooltip: l10n.send,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends ConsumerStatefulWidget {
  const _CommentTile({required this.comment, required this.postId, required this.onReply});

  final Comment comment;
  final String postId;
  final ValueChanged<Comment> onReply;

  @override
  ConsumerState<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<_CommentTile> {
  bool _showReplies = false;

  Comment get comment => widget.comment;

  Future<void> _toggleLike(Comment target, void Function(Comment) update) async {
    update(target.copyWith(isLiked: !target.isLiked, likesCount: target.likesCount + (target.isLiked ? -1 : 1)));
    try {
      final result = await ref.read(socialRepositoryProvider).toggleCommentLike(target.id);
      update(target.copyWith(isLiked: result.isLiked, likesCount: result.likesCount));
    } on ApiException {
      update(target);
    }
  }

  Future<void> _delete(Comment target) async {
    try {
      await ref.read(socialRepositoryProvider).deleteComment(target.id);
      if (target.parentId == null) {
        ref.read(commentsProvider(widget.postId).notifier).removeWhere((c) => c.id == target.id);
      } else {
        ref.read(repliesProvider(target.parentId!).notifier).removeWhere((c) => c.id == target.id);
      }
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    }
  }

  Widget _row(Comment item, {required bool isReply}) {
    final l10n = context.l10n;
    final update = isReply
        ? (Comment c) => ref.read(repliesProvider(item.parentId!).notifier).replaceWhere((x) => x.id == c.id, (_) => c)
        : (Comment c) => ref.read(commentsProvider(widget.postId).notifier).replaceWhere((x) => x.id == c.id, (_) => c);

    return Padding(
      padding: EdgeInsetsDirectional.only(top: AppSpacing.s, start: isReply ? 40 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(name: item.author.fullName, url: item.author.avatarUrl, radius: isReply ? 14 : 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.author.fullName,
                        style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: relativeTime(l10n, item.createdAt),
                        style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                      ),
                    ],
                  ),
                ),
                Text(item.text, style: AppTextStyles.body1),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => widget.onReply(item),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.reply, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
                    ),
                    if (item.canDelete)
                      TextButton(
                        onPressed: () => _delete(item),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(l10n.deletePost, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                      ),
                    if (!item.isMine)
                      TextButton(
                        onPressed: () => reportContent(
                          context,
                          ref.read(socialRepositoryProvider),
                          targetType: 'Comment',
                          targetId: item.id,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(l10n.report, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _toggleLike(item, update),
                icon: Icon(
                  item.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: item.isLiked ? AppColors.error : AppColors.black600,
                ),
              ),
              Text('${item.likesCount}', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final replies = _showReplies ? ref.watch(repliesProvider(comment.id)) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(comment, isReply: false),
        if (comment.repliesCount > 0)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 40),
            child: TextButton(
              onPressed: () => setState(() => _showReplies = !_showReplies),
              child: Text(
                _showReplies ? l10n.hideReplies : l10n.replies(comment.repliesCount),
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        if (replies != null) ...[
          for (final reply in replies.items) _row(reply, isReply: true),
          if (replies.isLoading)
            const Padding(padding: EdgeInsets.all(AppSpacing.xs), child: LinearProgressIndicator()),
          if (replies.hasMore && !replies.isLoading)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 40),
              child: TextButton(
                onPressed: ref.read(repliesProvider(comment.id).notifier).loadMore,
                child: Text(l10n.replies(comment.repliesCount)),
              ),
            ),
        ],
      ],
    );
  }
}

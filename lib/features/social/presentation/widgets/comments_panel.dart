import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/relative_time.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snack.dart';
import '../../../../core/widgets/submit_mixin.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/social_controllers.dart';
import '../../data/social_models.dart';
import '../../data/social_repository.dart';
import '../report_sheet.dart';

// The comments of a post, in a sheet over the post (like TikTok) or under it on the post's own page.
Future<void> showCommentsSheet(BuildContext context, String postId) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (sheet) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(sheet).height * 0.72,
      child: CommentsPanel(postId: postId, inSheet: true),
    ),
  ),
);

class CommentsPanel extends ConsumerStatefulWidget {
  const CommentsPanel({super.key, required this.postId, this.header, this.inSheet = false});

  final String postId;
  // Shown above the comments, scrolling with them (the post itself on its own page).
  final Widget? header;
  final bool inSheet;

  @override
  ConsumerState<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends ConsumerState<CommentsPanel> with SubmitMixin {
  final _text = TextEditingController();
  final _focus = FocusNode();
  Comment? _replyingTo;
  final _expanded = <String>{};

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startReply(Comment target) {
    setState(() => _replyingTo = target);
    _focus.requestFocus();
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
        final threadId = target.parentId ?? target.id;
        ref.invalidate(repliesProvider(threadId));
        ref
            .read(commentsProvider(widget.postId).notifier)
            .replaceWhere((c) => c.id == threadId, (c) => c.copyWith(repliesCount: c.repliesCount + 1));
        // The thread opens so the answer is seen where it landed.
        if (mounted) setState(() => _expanded.add(threadId));
      }
    });

    if (done && mounted) {
      _text.clear();
      setState(() => _replyingTo = null);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final comments = ref.watch(commentsProvider(widget.postId));
    final controller = ref.read(commentsProvider(widget.postId).notifier);
    final me = ref.watch(authControllerProvider).valueOrNull;

    return Column(
      children: [
        if (widget.inSheet)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(l10n.commentsCount(comments.items.length), style: AppTextStyles.body1Semibold),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.extentAfter < 300) controller.loadMore();
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              children: [
                ?widget.header,
                if (!widget.inSheet)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.m),
                    child: Text(l10n.comments, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                  ),
                if (comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Center(child: Text(l10n.noComments, style: AppTextStyles.body2)),
                  ),
                for (final comment in comments.items)
                  _CommentTile(
                    key: ValueKey(comment.id),
                    comment: comment,
                    postId: widget.postId,
                    expanded: _expanded.contains(comment.id),
                    highlightedId: _replyingTo?.id,
                    onToggle: () => setState(
                      () => _expanded.contains(comment.id) ? _expanded.remove(comment.id) : _expanded.add(comment.id),
                    ),
                    onReply: _startReply,
                  ),
                if (comments.isLoading)
                  const Padding(padding: EdgeInsets.all(AppSpacing.s), child: LinearProgressIndicator()),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: AppColors.gray200),
        SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_replyingTo != null)
                Container(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  padding: const EdgeInsetsDirectional.only(start: AppSpacing.s),
                  child: Row(
                    children: [
                      Icon(Icons.reply, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.replyingTo(_replyingTo!.author.fullName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _replyingTo = null),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Row(
                  children: [
                    UserAvatar(name: me?.fullName ?? '', radius: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _text,
                        focusNode: _focus,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: AppTextStyles.body1,
                        decoration: InputDecoration(
                          hintText: l10n.writeComment,
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton.filled(
                      onPressed: isSubmitting ? null : _send,
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.send_rounded, color: AppColors.onBrand, size: 20),
                      tooltip: l10n.send,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({
    super.key,
    required this.comment,
    required this.postId,
    required this.expanded,
    required this.highlightedId,
    required this.onToggle,
    required this.onReply,
  });

  final Comment comment;
  final String postId;
  final bool expanded;
  final String? highlightedId;
  final VoidCallback onToggle;
  final ValueChanged<Comment> onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final replies = expanded ? ref.watch(repliesProvider(comment.id)) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentRow(
          comment: comment,
          postId: postId,
          isReply: false,
          highlighted: highlightedId == comment.id,
          onReply: onReply,
        ),
        if (comment.repliesCount > 0)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 44),
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 24, height: 1, color: AppColors.gray400),
                    const SizedBox(width: 8),
                    Text(
                      expanded ? l10n.hideReplies : l10n.replies(comment.repliesCount),
                      style: AppTextStyles.caption.copyWith(color: AppColors.black600, fontWeight: FontWeight.w700),
                    ),
                    Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.black600),
                  ],
                ),
              ),
            ),
          ),
        if (replies != null) ...[
          for (final reply in replies.items)
            _CommentRow(
              comment: reply,
              postId: postId,
              isReply: true,
              highlighted: highlightedId == reply.id,
              onReply: onReply,
            ),
          if (replies.isLoading)
            const Padding(padding: EdgeInsets.all(AppSpacing.xs), child: LinearProgressIndicator()),
          if (replies.hasMore && !replies.isLoading)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 44),
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

class _CommentRow extends ConsumerWidget {
  const _CommentRow({
    required this.comment,
    required this.postId,
    required this.isReply,
    required this.highlighted,
    required this.onReply,
  });

  final Comment comment;
  final String postId;
  final bool isReply;
  final bool highlighted;
  final ValueChanged<Comment> onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repository = ref.read(socialRepositoryProvider);

    void update(Comment c) {
      if (isReply) {
        ref.read(repliesProvider(comment.parentId!).notifier).replaceWhere((x) => x.id == c.id, (_) => c);
      } else {
        ref.read(commentsProvider(postId).notifier).replaceWhere((x) => x.id == c.id, (_) => c);
      }
    }

    Future<void> like() async {
      update(comment.copyWith(isLiked: !comment.isLiked, likesCount: comment.likesCount + (comment.isLiked ? -1 : 1)));
      try {
        final result = await repository.toggleCommentLike(comment.id);
        update(comment.copyWith(isLiked: result.isLiked, likesCount: result.likesCount));
      } on ApiException {
        update(comment);
      }
    }

    Future<void> delete() async {
      try {
        await repository.deleteComment(comment.id);
        if (isReply) {
          ref.read(repliesProvider(comment.parentId!).notifier).removeWhere((c) => c.id == comment.id);
        } else {
          ref.read(commentsProvider(postId).notifier).removeWhere((c) => c.id == comment.id);
        }
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    final target = comment.replyTo;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: EdgeInsetsDirectional.only(top: AppSpacing.xs, start: isReply ? 44 : 0, bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: UserAvatar(name: comment.author.fullName, url: comment.author.avatarUrl, radius: isReply ? 14 : 18),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.author.fullName,
                        style: AppTextStyles.caption.copyWith(color: AppColors.black600, fontWeight: FontWeight.w700),
                      ),
                      // Who this answers: a reply under a thread can be to the author of the thread or to another reply.
                      if (isReply && target != null) ...[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.black600),
                          ),
                        ),
                        TextSpan(
                          text: target.fullName,
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(comment.text, style: AppTextStyles.body1),
                Row(
                  children: [
                    Text(
                      relativeTime(l10n, comment.createdAt),
                      style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    InkWell(
                      onTap: () => onReply(comment),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.reply,
                          style: AppTextStyles.caption.copyWith(color: AppColors.black600, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (comment.canDelete || !comment.isMine)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_horiz, size: 18, color: AppColors.black600),
                        onSelected: (value) {
                          if (value == 'delete') {
                            delete();
                          } else {
                            reportContent(context, repository, targetType: 'Comment', targetId: comment.id);
                          }
                        },
                        itemBuilder: (_) => [
                          if (comment.canDelete) PopupMenuItem(value: 'delete', child: Text(l10n.deletePost)),
                          if (!comment.isMine) PopupMenuItem(value: 'report', child: Text(l10n.report)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              InkWell(
                onTap: like,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    comment.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: comment.isLiked ? AppColors.error : AppColors.black600,
                  ),
                ),
              ),
              Text('${comment.likesCount}', style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
            ],
          ),
        ],
      ),
    );
  }
}

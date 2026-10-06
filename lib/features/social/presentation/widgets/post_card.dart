import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/relative_time.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/snack.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/dispose_soon.dart';
import '../../../../core/widgets/image_carousel.dart';
import '../../application/post_actions.dart';
import 'comments_panel.dart';
import '../../application/post_patches.dart';
import '../../data/social_models.dart';
import '../../data/social_repository.dart';
import '../report_sheet.dart';
import 'post_video.dart';

enum _PostAction { edit, delete, report }

// A post in a list: author, text, pictures or video, and the like / comment buttons. [detailed] is the post's own
// screen: no "open" tap, and the video plays in place.
class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, this.detailed = false});

  final Post post;
  final bool detailed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final patch = ref.watch(postPatchesProvider.select((patches) => patches[post.id]));
    if (patch?.isDeleted ?? false) return const SizedBox.shrink();

    final shown = post.apply(patch);
    final repository = ref.read(socialRepositoryProvider);

    final actions = PostActions(ref);
    Future<void> like() => actions.toggleLike(shown);

    Future<void> save() async {
      final saved = await actions.toggleSave(shown);
      if (saved != null && context.mounted) showSnack(context, saved ? l10n.postSaved : l10n.postUnsaved);
    }

    Future<void> share() async {
      if (!await actions.share(shown, l10n.appName) && context.mounted) showSnack(context, l10n.shareFailed);
    }

    Future<void> onAction(_PostAction action) async {
      switch (action) {
        case _PostAction.edit:
          await _edit(context, ref, shown);
        case _PostAction.delete:
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deletePost),
              content: Text(l10n.deletePostBody),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.deletePost, style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
          try {
            await repository.deletePost(shown.id);
            ref.read(postPatchesProvider.notifier).patch(shown.id, const PostPatch(isDeleted: true));
            if (detailed && context.mounted) context.pop();
          } on ApiException catch (e) {
            if (context.mounted) showApiError(context, e);
          }
        case _PostAction.report:
          await reportContent(context, repository, targetType: 'Post', targetId: shown.id);
      }
    }

    return AppCard(
      onTap: detailed ? null : () => context.push('/post/${shown.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, AppSpacing.xs, 0),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.push('/user/${shown.author.userId}'),
                  borderRadius: BorderRadius.circular(24),
                  child: UserAvatar(name: shown.author.fullName, url: shown.author.avatarUrl),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shown.author.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body1Semibold,
                      ),
                      Text(
                        relativeTime(l10n, shown.createdAt),
                        style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_PostAction>(
                  onSelected: onAction,
                  itemBuilder: (_) => [
                    if (shown.isMine) ...[
                      PopupMenuItem(value: _PostAction.edit, child: Text(l10n.editPost)),
                      PopupMenuItem(value: _PostAction.delete, child: Text(l10n.deletePost)),
                    ] else
                      PopupMenuItem(value: _PostAction.report, child: Text(l10n.report)),
                  ],
                ),
              ],
            ),
          ),
          if (shown.text?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.xs, AppSpacing.s, 0),
              child: Text(shown.text!, style: AppTextStyles.body1),
            ),
          if (shown.status == PostStatus.processing)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Text(l10n.postProcessing, style: AppTextStyles.body2.copyWith(color: AppColors.primaryMid)),
            ),
          if (shown.status == PostStatus.failed)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Text(l10n.postFailed, style: AppTextStyles.body2.copyWith(color: AppColors.error)),
            ),
          _Media(post: shown, playVideo: detailed),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.s, AppSpacing.xs),
            child: Row(
              children: [
                IconButton(
                  onPressed: like,
                  icon: Icon(
                    shown.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: shown.isLiked ? AppColors.error : AppColors.black600,
                  ),
                ),
                Text('${shown.likesCount}', style: AppTextStyles.body2),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: () => showCommentsSheet(context, shown.id),
                  icon: Icon(Icons.mode_comment_outlined, color: AppColors.black600),
                ),
                Text('${shown.commentsCount}', style: AppTextStyles.body2),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: share,
                  icon: Icon(Icons.share_outlined, color: AppColors.black600),
                ),
                const Spacer(),
                if (shown.hasVideo) ...[
                  Icon(Icons.visibility_outlined, size: 18, color: AppColors.black600),
                  const SizedBox(width: 4),
                  Text('${shown.viewsCount}', style: AppTextStyles.body2),
                  const SizedBox(width: AppSpacing.xs),
                ],
                IconButton(
                  onPressed: save,
                  icon: Icon(
                    shown.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: shown.isSaved ? AppColors.primary : AppColors.black600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Post shown) async {
    final l10n = context.l10n;
    final text = TextEditingController(text: shown.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editPost),
        content: TextField(controller: text, maxLines: 5, maxLength: 2000),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
        ],
      ),
    );
    final value = text.text.trim();
    disposeSoon(text);
    if (saved != true) return;

    try {
      await ref.read(socialRepositoryProvider).editPost(shown.id, value.isEmpty ? null : value);
      ref.read(postPatchesProvider.notifier).patch(shown.id, PostPatch(text: value));
    } on ApiException catch (e) {
      if (context.mounted) showApiError(context, e);
    }
  }
}

class _Media extends StatefulWidget {
  const _Media({required this.post, required this.playVideo});

  final Post post;
  final bool playVideo;

  @override
  State<_Media> createState() => _MediaState();
}

class _MediaState extends State<_Media> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final video = post.video;

    if (video != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: _playing || widget.playVideo
            ? SizedBox(
                height: 320,
                child: PostVideo(postId: post.id, media: video, autoPlay: true),
              )
            : GestureDetector(
                onTap: () => setState(() => _playing = true),
                child: SizedBox(
                  height: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(url: video.thumbnailUrl, icon: Icons.videocam_outlined),
                      const Center(child: Icon(Icons.play_circle_fill, color: AppColors.onBrand, size: 56)),
                    ],
                  ),
                ),
              ),
      );
    }

    final images = post.images;
    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SizedBox(height: 340, child: ImageCarousel(urls: [for (final image in images) image.url!])),
    );
  }
}

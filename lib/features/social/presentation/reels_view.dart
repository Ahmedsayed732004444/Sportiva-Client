import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/post_patches.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';
import 'widgets/post_video.dart';

// Full-screen videos, one at a time: swipe up for the next. Only the video on screen plays.
class ReelsView extends ConsumerStatefulWidget {
  const ReelsView({super.key});

  @override
  ConsumerState<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends ConsumerState<ReelsView> {
  final _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelsProvider);
    final controller = ref.read(reelsProvider.notifier);

    if (state.isFirstLoad) return const LoadingView();
    if (state.error != null && state.items.isEmpty) return ErrorView(error: state.error!, onRetry: controller.loadMore);
    if (state.isEmpty) return EmptyView(message: context.l10n.noReels, icon: Icons.slow_motion_video_outlined);

    return PageView.builder(
      controller: _pages,
      scrollDirection: Axis.vertical,
      itemCount: state.items.length,
      onPageChanged: (page) {
        if (page >= state.items.length - 2) controller.loadMore();
      },
      itemBuilder: (context, index) => _Reel(post: state.items[index]),
    );
  }
}

class _Reel extends ConsumerWidget {
  const _Reel({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = post.video;
    final patch = ref.watch(postPatchesProvider.select((patches) => patches[post.id]));
    final shown = post.apply(patch);

    Future<void> like() async {
      final patches = ref.read(postPatchesProvider.notifier);
      patches.patch(
        shown.id,
        PostPatch(isLiked: !shown.isLiked, likesCount: shown.likesCount + (shown.isLiked ? -1 : 1)),
      );
      try {
        final result = await ref.read(socialRepositoryProvider).toggleLike(shown.id);
        patches.patch(shown.id, PostPatch(isLiked: result.isLiked, likesCount: result.likesCount));
      } on Object {
        patches.patch(shown.id, PostPatch(isLiked: shown.isLiked, likesCount: shown.likesCount));
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (video != null) PostVideo(postId: post.id, media: video, autoPlay: true, fill: true),
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Color(0xAA000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: AppSpacing.s,
          end: 88,
          bottom: AppSpacing.l,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => context.push('/user/${shown.author.userId}'),
                child: Row(
                  children: [
                    UserAvatar(name: shown.author.fullName, url: shown.author.avatarUrl, radius: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        shown.author.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body1Semibold.copyWith(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              if (shown.text?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    shown.text!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(color: AppColors.white),
                  ),
                ),
            ],
          ),
        ),
        PositionedDirectional(
          end: AppSpacing.xs,
          bottom: AppSpacing.l,
          child: Column(
            children: [
              IconButton(
                onPressed: like,
                icon: Icon(
                  shown.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: shown.isLiked ? AppColors.error : AppColors.white,
                  size: 32,
                ),
              ),
              Text('${shown.likesCount}', style: const TextStyle(color: AppColors.white)),
              const SizedBox(height: AppSpacing.s),
              IconButton(
                onPressed: () => context.push('/post/${shown.id}'),
                icon: const Icon(Icons.mode_comment_outlined, color: AppColors.white, size: 30),
              ),
              Text('${shown.commentsCount}', style: const TextStyle(color: AppColors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

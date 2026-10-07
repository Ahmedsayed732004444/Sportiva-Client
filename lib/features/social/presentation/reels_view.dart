import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/post_actions.dart';
import '../application/post_patches.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import 'widgets/comments_panel.dart';
import 'widgets/post_video.dart';

const _shadow = [Shadow(color: Color(0x99000000), blurRadius: 6)];

// The "for you" pager, one post at a time: swipe up for the next. Only the post on screen plays, and the ones next to
// it are prepared (never more), so swiping is smooth without downloading videos nobody watches.
class ReelsView extends ConsumerStatefulWidget {
  const ReelsView({super.key});

  @override
  ConsumerState<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends ConsumerState<ReelsView> {
  final _pages = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forYouProvider);
    final controller = ref.read(forYouProvider.notifier);

    if (state.isFirstLoad) return const _OnBlack(child: LoadingView());
    if (state.error != null && state.items.isEmpty) {
      return _OnBlack(
        child: ErrorView(error: state.error!, onRetry: controller.loadMore),
      );
    }
    if (state.isEmpty) {
      return _OnBlack(
        child: EmptyView(message: context.l10n.noReels, icon: Icons.slow_motion_video_outlined),
      );
    }

    return ColoredBox(
      color: AppColors.scrim,
      child: PageView.builder(
        controller: _pages,
        scrollDirection: Axis.vertical,
        allowImplicitScrolling: true,
        itemCount: state.items.length,
        onPageChanged: (page) {
          setState(() => _current = page);
          if (page >= state.items.length - 3) controller.loadMore();
        },
        itemBuilder: (context, index) => _Reel(post: state.items[index], active: index == _current),
      ),
    );
  }
}

class _OnBlack extends StatelessWidget {
  const _OnBlack({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.scrim,
    child: Center(child: child),
  );
}

class _Reel extends ConsumerStatefulWidget {
  const _Reel({required this.post, required this.active});

  final Post post;
  final bool active;

  @override
  ConsumerState<_Reel> createState() => _ReelState();
}

class _ReelState extends ConsumerState<_Reel> {
  bool _captionOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final post = widget.post;
    final patch = ref.watch(postPatchesProvider.select((patches) => patches[post.id]));
    final shown = post.apply(patch);
    final following =
        ref.watch(authorFollowsProvider.select((follows) => follows[post.author.userId])) ?? post.isFollowingAuthor;
    final actions = PostActions(ref);
    final video = shown.video;
    if (widget.active) actions.recordSeen(shown);

    Future<void> save() async {
      final saved = await actions.toggleSave(shown);
      if (saved != null && context.mounted) showSnack(context, saved ? l10n.postSaved : l10n.postUnsaved);
    }

    Future<void> share() async {
      if (!await actions.share(shown, l10n.appName) && context.mounted) showSnack(context, l10n.shareFailed);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: shown.isLiked ? null : () => actions.toggleLike(shown),
          child: video != null
              ? PostVideo(postId: post.id, media: video, autoPlay: true, smartFit: true, active: widget.active)
              : _Photos(images: [for (final image in shown.images) image.url!]),
        ),
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
        // The caption: who, and what they said (tap for the rest).
        PositionedDirectional(
          start: 14,
          end: 84,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => context.push('/user/${shown.author.userId}'),
                child: Text(
                  shown.author.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.onBrand,
                    fontWeight: FontWeight.w800,
                    shadows: _shadow,
                  ),
                ),
              ),
              if (shown.text?.isNotEmpty ?? false)
                GestureDetector(
                  onTap: () => setState(() => _captionOpen = !_captionOpen),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: shown.text!),
                            if (!_captionOpen && shown.text!.length > 70)
                              TextSpan(
                                text: '  ${l10n.showMore}',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                          ],
                        ),
                        maxLines: _captionOpen ? 12 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body1.copyWith(color: AppColors.onBrand, shadows: _shadow),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // The rail of buttons on the side.
        PositionedDirectional(
          end: 8,
          bottom: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AuthorButton(
                post: shown,
                showFollow: !shown.isMine && !following,
                onOpen: () => context.push('/user/${shown.author.userId}'),
                onFollow: () => actions.follow(shown),
              ),
              const SizedBox(height: 18),
              _RailButton(
                icon: Icons.favorite,
                color: shown.isLiked ? const Color(0xFFFF2D55) : AppColors.onBrand,
                label: _compact(shown.likesCount),
                onTap: () => actions.toggleLike(shown),
              ),
              _RailButton(
                icon: Icons.sms,
                label: _compact(shown.commentsCount),
                onTap: () => showCommentsSheet(context, shown.id),
              ),
              if (!shown.isMine)
                _RailButton(
                  icon: Icons.repeat,
                  color: shown.isReposted ? const Color(0xFF25F4EE) : AppColors.onBrand,
                  label: _compact(shown.repostsCount),
                  onTap: () async {
                    final done = await actions.toggleRepost(shown);
                    if (done != null && context.mounted) showSnack(context, done ? l10n.repostDone : l10n.repostUndone);
                  },
                ),
              _RailButton(
                icon: Icons.bookmark,
                color: shown.isSaved ? const Color(0xFFFFC107) : AppColors.onBrand,
                label: _compact(shown.savesCount),
                onTap: save,
              ),
              _RailButton(icon: Icons.reply, flip: true, label: l10n.sharePost, onTap: share),
            ],
          ),
        ),
      ],
    );
  }
}

String _compact(int value) => value >= 1000000
    ? '${(value / 1000000).toStringAsFixed(1)}M'
    : value >= 1000
    ? '${(value / 1000).toStringAsFixed(1)}K'
    : '$value';

class _RailButton extends StatelessWidget {
  const _RailButton({required this.icon, required this.label, required this.onTap, this.color, this.flip = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(icon, size: 38, color: color ?? AppColors.onBrand, shadows: _shadow);

    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            flip ? Transform.flip(flipX: true, child: glyph) : glyph,
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onBrand,
                fontWeight: FontWeight.w700,
                shadows: _shadow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The author's picture with the red "+" under it that follows them.
class _AuthorButton extends StatelessWidget {
  const _AuthorButton({required this.post, required this.showFollow, required this.onOpen, required this.onFollow});

  final Post post;
  final bool showFollow;
  final VoidCallback onOpen;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 66,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: AppColors.onBrand, shape: BoxShape.circle),
              child: UserAvatar(name: post.author.fullName, url: post.author.avatarUrl, radius: 24),
            ),
          ),
          if (showFollow)
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onTap: onFollow,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Color(0xFFFF2D55), shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 18, color: AppColors.onBrand),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// A photo post: the pictures one by one with dots under them, whole (never cropped).
class _Photos extends StatefulWidget {
  const _Photos({required this.images});

  final List<String> images;

  @override
  State<_Photos> createState() => _PhotosState();
}

class _PhotosState extends State<_Photos> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (page) => setState(() => _page = page),
          itemBuilder: (_, index) => CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(child: CircularProgressIndicator(color: AppColors.onBrand)),
            errorWidget: (_, _, _) =>
                const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.onBrand, size: 48)),
          ),
        ),
        if (images.length > 1)
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 110,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page ? AppColors.onBrand : AppColors.onBrand.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

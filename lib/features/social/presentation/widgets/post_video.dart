import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/social_models.dart';
import '../../data/social_repository.dart';

// A post's video. It streams the adaptive (HLS) version and falls back to the plain MP4 when that can't play.
// How much was watched is reported when the player goes away.
//
// It plays only while it should: the post is the one on screen ([active]), the screen it is on is the one in front
// (not behind another page or another tab of the app), and the app itself is in front. Anything else pauses it.
class PostVideo extends ConsumerStatefulWidget {
  const PostVideo({
    super.key,
    required this.postId,
    required this.media,
    this.autoPlay = false,
    this.fill = false,
    this.smartFit = false,
    this.active = true,
  });

  final String postId;
  final PostMedia media;
  final bool autoPlay;
  // Fill the space (cropping what does not fit).
  final bool fill;
  // Like TikTok: a tall video fills the screen, a wide one keeps its proportions in the middle.
  final bool smartFit;
  final bool active;

  @override
  ConsumerState<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends ConsumerState<PostVideo> with WidgetsBindingObserver {
  late final SocialRepository _repository = ref.read(socialRepositoryProvider);
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _started = false;
  bool _userPaused = false;
  bool _screenInFront = true;
  bool _appInFront = true;
  int _watched = 0;

  bool get _shouldPlay => widget.autoPlay && widget.active && _screenInFront && _appInFront && !_userPaused;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open(widget.media.url, fallback: widget.media.fallbackUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A screen under another page, or an app tab that is not shown, has its tickers switched off.
    final front = TickerMode.valuesOf(context).enabled;
    if (front != _screenInFront) {
      _screenInFront = front;
      _sync();
    }
  }

  @override
  void didUpdateWidget(PostVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _userPaused = false;
      // Coming back to a reel starts it over, like TikTok.
      if (!widget.active) _controller?.seekTo(Duration.zero);
      _sync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appInFront = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    final controller = _controller;
    if (controller == null) return;
    if (_shouldPlay) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  Future<void> _open(String? url, {String? fallback}) async {
    if (url == null) {
      setState(() => _failed = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
    } on Object {
      await controller.dispose();
      if (fallback != null) return _open(fallback);
      if (mounted) setState(() => _failed = true);
      return;
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }

    controller
      ..setLooping(widget.autoPlay)
      ..addListener(_track);
    setState(() => _controller = controller);
    _sync();
  }

  void _track() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) _started = true;
    final seconds = controller.value.position.inSeconds;
    if (seconds > _watched) _watched = seconds;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    if (_started) {
      final total = controller?.value.duration.inSeconds ?? 0;
      _repository
          .recordView(
            widget.postId,
            watchedSeconds: _watched.clamp(0, 3600),
            completed: total > 0 && _watched >= total - 1,
          )
          .catchError((Object _) {});
    }
    controller?.removeListener(_track);
    controller?.pause();
    controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _userPaused = controller.value.isPlaying);
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_failed) {
      return ColoredBox(
        color: AppColors.scrim,
        child: Center(
          child: Text(context.l10n.videoUnavailable, style: const TextStyle(color: AppColors.onBrand)),
        ),
      );
    }
    if (controller == null) {
      // The picture the video starts with, so the screen is never empty while it loads.
      return ColoredBox(
        color: AppColors.scrim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.media.thumbnailUrl != null)
              Opacity(
                opacity: 0.6,
                child: AppNetworkImage(url: widget.media.thumbnailUrl, icon: Icons.videocam_outlined),
              ),
            const Center(child: CircularProgressIndicator(color: AppColors.onBrand)),
          ],
        ),
      );
    }

    final size = controller.value.size;
    final aspect = size.height == 0 ? 1.0 : size.width / size.height;
    final fills = widget.fill || (widget.smartFit && aspect <= 0.75);

    final player = fills
        ? FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(width: size.width, height: size.height, child: VideoPlayer(controller)),
          )
        : Center(
            child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: ColoredBox(
        color: AppColors.scrim,
        child: Stack(
          alignment: Alignment.center,
          children: [
            player,
            if (_userPaused) const Icon(Icons.play_arrow_rounded, color: AppColors.onBrand, size: 84),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: VideoProgressColors(
                  playedColor: AppColors.onBrand,
                  bufferedColor: AppColors.onBrand.withValues(alpha: 0.3),
                  backgroundColor: AppColors.onBrand.withValues(alpha: 0.15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/social_models.dart';
import '../../data/social_repository.dart';

// A post's video. It streams the adaptive (HLS) version and falls back to the plain MP4 when that can't play.
// How much was watched is reported when the player goes away.
class PostVideo extends ConsumerStatefulWidget {
  const PostVideo({super.key, required this.postId, required this.media, this.autoPlay = false, this.fill = false});

  final String postId;
  final PostMedia media;
  final bool autoPlay;
  // Reels fill their screen; in a card the video keeps its own proportions.
  final bool fill;

  @override
  ConsumerState<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends ConsumerState<PostVideo> {
  late final SocialRepository _repository = ref.read(socialRepositoryProvider);
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _started = false;
  int _watched = 0;

  @override
  void initState() {
    super.initState();
    _open(widget.media.url, fallback: widget.media.fallbackUrl);
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
    if (widget.autoPlay) await controller.play();
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
    controller?.dispose();
    super.dispose();
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
      return const ColoredBox(
        color: AppColors.scrim,
        child: Center(child: CircularProgressIndicator(color: AppColors.onBrand)),
      );
    }

    final player = widget.fill
        ? FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          )
        : AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller));

    return GestureDetector(
      onTap: () => controller.value.isPlaying ? controller.pause() : controller.play(),
      child: ColoredBox(
        color: AppColors.scrim,
        child: Stack(
          alignment: Alignment.center,
          children: [
            player,
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (_, value, _) => value.isPlaying
                  ? const SizedBox.shrink()
                  : const Icon(Icons.play_circle_fill, color: AppColors.onBrand, size: 64),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: VideoProgressColors(playedColor: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

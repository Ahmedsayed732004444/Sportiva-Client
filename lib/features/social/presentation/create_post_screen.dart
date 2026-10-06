import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/social_controllers.dart';
import '../data/social_repository.dart';

// A post is text, up to 10 photos, or one video. Photos and video are prepared in the background after publishing.
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> with SubmitMixin {
  static const _maxImages = 10;
  static const _maxVideoBytes = 100 * 1024 * 1024;

  final _text = TextEditingController();
  final _picker = ImagePicker();
  List<XFile> _images = [];
  XFile? _video;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(limit: _maxImages);
    if (picked.isEmpty) return;
    final all = [..._images, ...picked];
    setState(() {
      _images = all.take(_maxImages).toList();
      _video = null;
    });
    if (all.length > _maxImages && mounted) showMessage(context.l10n.maxPhotos(_maxImages));
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    if (await picked.length() > _maxVideoBytes) {
      if (mounted) showMessage(context.l10n.videoTooLarge);
      return;
    }
    setState(() {
      _video = picked;
      _images = [];
    });
  }

  Future<void> _publish() async {
    final l10n = context.l10n;
    if (_text.text.trim().isEmpty && _images.isEmpty && _video == null) {
      showMessage(l10n.postEmpty);
      return;
    }

    final hasMedia = _images.isNotEmpty || _video != null;
    final done = await submit(
      () => ref
          .read(socialRepositoryProvider)
          .createPost(text: _text.text, imagePaths: [for (final i in _images) i.path], videoPath: _video?.path),
    );

    if (done && mounted) {
      showMessage(hasMedia ? l10n.postProcessing : l10n.postPublished);
      ref.invalidate(feedProvider);
      ref.invalidate(exploreProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newPost)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          TextField(
            controller: _text,
            maxLines: 6,
            maxLength: 2000,
            style: AppTextStyles.body1,
            decoration: InputDecoration(hintText: l10n.whatsOnYourMind),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.addPhotos),
              ),
              const SizedBox(width: AppSpacing.s),
              OutlinedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam_outlined),
                label: Text(l10n.addVideo),
              ),
            ],
          ),
          if (_images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s),
              child: SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_images[index].path), width: 96, height: 96, fit: BoxFit.cover),
                      ),
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: InkWell(
                          onTap: () => setState(() => _images = [..._images]..removeAt(index)),
                          child: const CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.scrim,
                            child: Icon(Icons.close, size: 14, color: AppColors.onBrand),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_video != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.movie_outlined, color: AppColors.primary),
              title: Text(l10n.videoPicked, style: AppTextStyles.body1),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.removeVideo,
                onPressed: () => setState(() => _video = null),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          AppButton(label: l10n.publish, onPressed: _publish, isLoading: isSubmitting),
        ],
      ),
    );
  }
}

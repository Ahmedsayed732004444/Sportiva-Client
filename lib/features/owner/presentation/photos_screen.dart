import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../application/owner_controllers.dart';
import '../data/owner_club_repository.dart';
import '../data/owner_court_models.dart';
import '../data/owner_court_repository.dart';

// The gallery of the club (courtId null) or of one court: add photos, delete them, and (courts) pick the cover.
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key, this.courtId});

  final String? courtId;

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  List<GalleryImage>? _images;
  ApiException? _error;
  bool _busy = false;

  bool get _isCourt => widget.courtId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final images = _isCourt
          ? (await ref.read(ownerCourtRepositoryProvider).get(widget.courtId!)).images
          : (await ref.read(ownerClubRepositoryProvider).club()).images;
      if (mounted) setState(() => _images = images);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ownerCourtsProvider);
      ref.invalidate(ownerClubProvider);
      await _load();
      if (mounted) showSnack(context, done);
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 2000, limit: 10);
    if (picked.isEmpty || !mounted) return;
    final paths = [for (final file in picked) file.path];
    await _run(
      () => _isCourt
          ? ref.read(ownerCourtRepositoryProvider).addImages(widget.courtId!, paths)
          : ref.read(ownerClubRepositoryProvider).addImages(paths),
      context.l10n.photoAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final images = _images;

    return Scaffold(
      appBar: AppBar(title: Text(_isCourt ? l10n.courtPhotos : l10n.clubPhotos)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onBrand,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n.addPhotos2),
      ),
      body: _error != null
          ? ErrorView(error: _error!, onRetry: _load)
          : images == null
          ? const LoadingView()
          : images.isEmpty
          ? EmptyView(message: l10n.noPhotos, icon: Icons.photo_library_outlined)
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.s),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.s,
                crossAxisSpacing: AppSpacing.s,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppNetworkImage(url: image.url),
                      if (image.isCover)
                        PositionedDirectional(
                          top: 6,
                          start: 6,
                          child: Icon(Icons.star_rounded, color: AppColors.primary),
                        ),
                      PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: PopupMenuButton<bool>(
                          icon: const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.scrim,
                            child: Icon(Icons.more_horiz, size: 16, color: AppColors.onBrand),
                          ),
                          onSelected: (delete) => delete
                              ? _run(
                                  () => _isCourt
                                      ? ref.read(ownerCourtRepositoryProvider).deleteImage(widget.courtId!, image.id)
                                      : ref.read(ownerClubRepositoryProvider).deleteImage(image.id),
                                  l10n.photoDeleted,
                                )
                              : _run(
                                  () => ref.read(ownerCourtRepositoryProvider).setCover(widget.courtId!, image.id),
                                  l10n.coverSet,
                                ),
                          itemBuilder: (_) => [
                            if (_isCourt && !image.isCover) PopupMenuItem(value: false, child: Text(l10n.setCover)),
                            PopupMenuItem(value: true, child: Text(l10n.deletePhoto)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

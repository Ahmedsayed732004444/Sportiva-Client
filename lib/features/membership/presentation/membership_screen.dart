import '../../../core/maps/location_picker_field.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../auth/application/auth_controller.dart';
import '../../matches/application/matches_controller.dart';
import '../application/membership_providers.dart';
import '../data/membership_models.dart';
import '../data/membership_repository.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  // After a rejection the user may start a new request.
  bool _writingNew = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = ref.watch(membershipProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.membershipTitle)),
      body: request.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(membershipProvider),
        ),
        data: (request) => request == null || _writingNew
            ? _Form(onSent: () => setState(() => _writingNew = false))
            : _Status(request: request, onNewRequest: () => setState(() => _writingNew = true)),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.onSent});

  final VoidCallback onSent;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> with SubmitMixin {
  static const _maxImages = 10;
  static const _maxVideos = 2;

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(authControllerProvider).valueOrNull?.fullName);
  final _phone = TextEditingController();
  final _club = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _location = TextEditingController();
  final _note = TextEditingController();
  final _picker = ImagePicker();
  int? _governorateId;
  List<XFile> _images = [];
  List<XFile> _videos = [];

  @override
  void dispose() {
    for (final controller in [_name, _phone, _club, _city, _address, _location, _note]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(limit: _maxImages, imageQuality: 85, maxWidth: 2000);
    if (picked.isNotEmpty) setState(() => _images = picked.take(_maxImages).toList());
  }

  Future<void> _pickVideo() async {
    if (_videos.length >= _maxVideos) {
      showMessage(context.l10n.tooManyVideos(_maxVideos));
      return;
    }
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => _videos = [..._videos, picked]);
  }

  String? _orNull(TextEditingController controller) => controller.text.trim().isEmpty ? null : controller.text.trim();

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final done = await submit(
      () => ref
          .read(membershipRepositoryProvider)
          .create(
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            clubName: _club.text.trim(),
            governorateId: _governorateId!,
            city: _city.text.trim(),
            address: _address.text.trim(),
            locationUrl: _orNull(_location),
            note: _orNull(_note),
            imagePaths: [for (final i in _images) i.path],
            videoPaths: [for (final v in _videos) v.path],
          ),
    );

    if (done && mounted) {
      showMessage(context.l10n.requestSentMembership);
      ref.invalidate(membershipProvider);
      widget.onSent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final validators = Validators(l10n);
    final governorates = ref.watch(governoratesProvider).valueOrNull ?? const [];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(l10n.membershipIntro, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.applicantName,
            hint: l10n.enterFullName,
            controller: _name,
            validator: validators.name,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.phone,
            hint: l10n.enterPhone,
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: validators.phone,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.clubNameField,
            hint: l10n.enterClubName,
            controller: _club,
            validator: validators.required,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.governorate, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            initialValue: _governorateId,
            isExpanded: true,
            validator: (value) => value == null ? l10n.fieldRequired : null,
            decoration: const InputDecoration(),
            style: AppTextStyles.body1,
            items: [for (final g in governorates) DropdownMenuItem(value: g.id, child: Text(g.name(locale)))],
            onChanged: (value) => setState(() => _governorateId = value),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(label: l10n.city, hint: l10n.enterCity, controller: _city, validator: validators.required),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.address,
            hint: l10n.addressHint,
            controller: _address,
            validator: validators.required,
          ),
          const SizedBox(height: AppSpacing.m),
          LocationPickerField(
            label: l10n.locationUrl,
            controller: _location,
            onAddress: (address) {
              if (_address.text.trim().isEmpty) _address.text = address;
            },
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.note,
            hint: l10n.enterNote,
            controller: _note,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.attachFiles, style: AppTextStyles.title),
          Text(
            l10n.attachHint(_maxImages, _maxVideos),
            style: AppTextStyles.caption.copyWith(color: AppColors.black600),
          ),
          const SizedBox(height: AppSpacing.xs),
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
                label: Text(l10n.addVideoShort),
              ),
            ],
          ),
          if (_images.isNotEmpty || _videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s),
              child: SizedBox(
                height: 84,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < _images.length; i++)
                      _Thumb(
                        child: Image.file(File(_images[i].path), width: 84, height: 84, fit: BoxFit.cover),
                        onRemove: () => setState(() => _images = [..._images]..removeAt(i)),
                      ),
                    for (var i = 0; i < _videos.length; i++)
                      _Thumb(
                        child: const ColoredBox(
                          color: AppColors.scrim,
                          child: SizedBox(
                            width: 84,
                            height: 84,
                            child: Icon(Icons.movie_outlined, color: AppColors.onBrand),
                          ),
                        ),
                        onRemove: () => setState(() => _videos = [..._videos]..removeAt(i)),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          AppButton(label: l10n.submitRequest, onPressed: _send, isLoading: isSubmitting),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
    child: Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: InkWell(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.scrim,
              child: Icon(Icons.close, size: 14, color: AppColors.onBrand),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Status extends ConsumerStatefulWidget {
  const _Status({required this.request, required this.onNewRequest});

  final MembershipRequest request;
  final VoidCallback onNewRequest;

  @override
  ConsumerState<_Status> createState() => _StatusState();
}

class _StatusState extends ConsumerState<_Status> {
  bool _busy = false;

  MembershipRequest get request => widget.request;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(membershipProvider);
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addFiles({required bool video}) async {
    final picker = ImagePicker();
    final repository = ref.read(membershipRepositoryProvider);
    if (video) {
      final picked = await picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) await _run(() => repository.addMedia(request.id, videoPaths: [picked.path]));
    } else {
      final picked = await picker.pickMultiImage(limit: 10, imageQuality: 85, maxWidth: 2000);
      if (picked.isNotEmpty) {
        await _run(() => repository.addMedia(request.id, imagePaths: [for (final i in picked) i.path]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, body, color) = switch (request.status) {
      MembershipStatus.pending => (l10n.membershipPending, l10n.membershipPendingBody, AppColors.primaryMid),
      MembershipStatus.approved => (l10n.membershipApproved, l10n.membershipApprovedBody, AppColors.primary),
      MembershipStatus.rejected => (l10n.membershipRejected, l10n.membershipRejectedBody, AppColors.error),
    };

    Widget row(String title, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body1Semibold)),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.title.copyWith(color: color, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(body, style: AppTextStyles.body2),
              if (request.status == MembershipStatus.rejected && (request.rejectionReason?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${l10n.rejectionReasonLabel}: ${request.rejectionReason}',
                    style: AppTextStyles.body2.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(l10n.yourRequest, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        row(l10n.clubNameField, request.clubName),
        row(l10n.governorate, '${request.governorateName} · ${request.city}'),
        row(l10n.address, request.address),
        row(l10n.phone, request.phone),
        if (request.note?.isNotEmpty ?? false) row(l10n.note, request.note!),
        if (request.media.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Text(l10n.attachFiles, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final media in request.media)
                SizedBox(
                  width: 96,
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (media.isReady)
                          AppNetworkImage(
                            url: media.thumbnailUrl ?? media.url,
                            icon: media.isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                          )
                        else
                          ColoredBox(
                            color: AppColors.gray200,
                            child: Center(
                              child: Text(
                                media.isFailed ? l10n.mediaFailed : l10n.mediaProcessing,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                        if (media.isVideo && media.isReady)
                          const Center(child: Icon(Icons.play_circle_fill, color: AppColors.onBrand, size: 32)),
                        if (request.status == MembershipStatus.pending)
                          PositionedDirectional(
                            top: 0,
                            end: 0,
                            child: InkWell(
                              onTap: () =>
                                  _run(() => ref.read(membershipRepositoryProvider).deleteMedia(request.id, media.id)),
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
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        if (request.status == MembershipStatus.pending)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _addFiles(video: false),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.addPhotos),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _addFiles(video: true),
                  icon: const Icon(Icons.videocam_outlined),
                  label: Text(l10n.addVideoShort),
                ),
              ),
            ],
          ),
        if (request.status == MembershipStatus.rejected)
          AppButton(label: l10n.newRequest, onPressed: widget.onNewRequest),
      ],
    );
  }
}

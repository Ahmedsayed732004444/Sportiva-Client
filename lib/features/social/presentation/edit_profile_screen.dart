import '../../../core/widgets/app_network_image.dart';
import '../data/player_traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/data/sport_type.dart';
import '../../matches/application/matches_controller.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).valueOrNull?.userId;
    final profile = userId == null ? null : ref.watch(profileProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editProfile)),
      body: profile == null
          ? const LoadingView()
          : profile.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(
                error: const ApiException(kind: ApiErrorKind.unknown),
                onRetry: () => ref.invalidate(profileProvider(userId!)),
              ),
              data: (profile) => _Form(profile: profile),
            ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late final _first = TextEditingController(text: widget.profile.firstName);
  late final _last = TextEditingController(text: widget.profile.lastName);
  late final _bio = TextEditingController(text: widget.profile.bio);
  late final _city = TextEditingController(text: widget.profile.city);
  late final Set<SportType> _sports = {...widget.profile.preferredSports};
  late int? _governorateId = widget.profile.governorateId;
  late PlayerPosition? _position = widget.profile.position;
  late PreferredFoot? _foot = widget.profile.foot;

  @override
  void dispose() {
    for (final controller in [_first, _last, _bio, _city]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;

    final done = await submit(() => ref.read(socialRepositoryProvider).setAvatar(picked.path));
    if (done) ref.invalidate(profileProvider(widget.profile.userId));
  }

  Future<void> _changeCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 2000);
    if (picked == null) return;

    final done = await submit(() => ref.read(socialRepositoryProvider).setCover(picked.path));
    if (done && mounted) {
      ref.invalidate(profileProvider(widget.profile.userId));
      showMessage(context.l10n.coverChanged);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final done = await submit(
      () => ref
          .read(socialRepositoryProvider)
          .updateProfile(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            preferredSports: _sports.toList(),
            bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
            city: _city.text.trim().isEmpty ? null : _city.text.trim(),
            governorateId: _governorateId,
            position: _position,
            foot: _foot,
          ),
    );

    if (done && mounted) {
      ref.invalidate(profileProvider(widget.profile.userId));
      showMessage(context.l10n.profileSaved);
      context.pop();
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
          // The cover across the top, the profile picture over its bottom edge.
          SizedBox(
            height: 190,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: AppNetworkImage(url: widget.profile.coverUrl, icon: Icons.landscape_outlined),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: FilledButton.tonalIcon(
                    onPressed: isSubmitting ? null : _changeCover,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text(context.l10n.changeCover),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: UserAvatar(name: widget.profile.fullName, url: widget.profile.avatarUrl, radius: 48),
                ),
              ],
            ),
          ),
          TextButton(onPressed: isSubmitting ? null : _changePhoto, child: Text(l10n.changePhoto)),
          const SizedBox(height: AppSpacing.s),
          AppTextField(label: l10n.firstName, hint: l10n.firstName, controller: _first, validator: validators.name),
          const SizedBox(height: AppSpacing.m),
          AppTextField(label: l10n.lastName, hint: l10n.lastName, controller: _last, validator: validators.name),
          const SizedBox(height: AppSpacing.m),
          AppTextField(label: l10n.bio, hint: l10n.enterBio, controller: _bio),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.preferredSports, style: AppTextStyles.title),
          Text(l10n.preferredSportsHint, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sport in SportType.values.where((sport) => sport != SportType.other))
                FilterChip(
                  avatar: Icon(sport.icon, size: 18),
                  label: Text(sport.label(l10n)),
                  selected: _sports.contains(sport),
                  onSelected: (on) => setState(() => on ? _sports.add(sport) : _sports.remove(sport)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.playerPosition, style: AppTextStyles.title),
          Text(l10n.traitsHint, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final position in PlayerPosition.values)
                ChoiceChip(
                  avatar: Icon(position.icon, size: 18),
                  label: Text(position.label(l10n)),
                  selected: _position == position,
                  // Tapping the chosen one again clears it.
                  onSelected: (on) => setState(() => _position = on ? position : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.preferredFoot, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final foot in PreferredFoot.values)
                ChoiceChip(
                  label: Text(foot.label(l10n)),
                  selected: _foot == foot,
                  onSelected: (on) => setState(() => _foot = on ? foot : null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.governorate, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            initialValue: _governorateId,
            isExpanded: true,
            decoration: const InputDecoration(),
            style: AppTextStyles.body1,
            items: [for (final g in governorates) DropdownMenuItem(value: g.id, child: Text(g.name(locale)))],
            onChanged: (value) => setState(() => _governorateId = value),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.city,
            hint: l10n.enterCity,
            controller: _city,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(label: l10n.save, onPressed: _save, isLoading: isSubmitting),
        ],
      ),
    );
  }
}

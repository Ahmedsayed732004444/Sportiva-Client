import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../matches/application/matches_controller.dart';
import '../application/owner_controllers.dart';
import '../data/owner_club_models.dart';
import '../data/owner_club_repository.dart';

class ClubEditScreen extends ConsumerWidget {
  const ClubEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(ownerClubProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editClubInfo)),
      body: club.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(ownerClubProvider),
        ),
        data: (club) => _Form(club: club),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.club});

  final OwnerClub club;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.club.name);
  late final _city = TextEditingController(text: widget.club.city);
  late final _address = TextEditingController(text: widget.club.address);
  late final _phone = TextEditingController(text: widget.club.phone);
  late final _email = TextEditingController(text: widget.club.email);
  late final _map = TextEditingController(text: widget.club.mapUrl);
  late int _governorateId = widget.club.governorateId;

  @override
  void dispose() {
    for (final controller in [_name, _city, _address, _phone, _email, _map]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _orNull(TextEditingController controller) => controller.text.trim().isEmpty ? null : controller.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final done = await submit(
      () => ref
          .read(ownerClubRepositoryProvider)
          .update(
            name: _name.text.trim(),
            governorateId: _governorateId,
            city: _city.text.trim(),
            address: _address.text.trim(),
            phone: _phone.text.trim(),
            mapUrl: _orNull(_map),
            email: _orNull(_email),
          ),
    );
    if (done && mounted) {
      ref.invalidate(ownerClubProvider);
      showMessage(context.l10n.clubSaved);
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
          AppTextField(label: l10n.club, hint: l10n.club, controller: _name, validator: validators.required),
          const SizedBox(height: AppSpacing.m),
          Text(l10n.governorate, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            initialValue: governorates.any((g) => g.id == _governorateId) ? _governorateId : null,
            isExpanded: true,
            decoration: const InputDecoration(),
            items: [for (final g in governorates) DropdownMenuItem(value: g.id, child: Text(g.name(locale)))],
            onChanged: (value) => setState(() => _governorateId = value ?? _governorateId),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(label: l10n.city, hint: l10n.enterCity, controller: _city, validator: validators.required),
          const SizedBox(height: AppSpacing.m),
          AppTextField(label: l10n.address, hint: l10n.address, controller: _address, validator: validators.required),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.clubPhone,
            hint: l10n.enterPhone,
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: validators.phone,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.clubEmail,
            hint: l10n.clubEmail,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value ?? '').trim().isEmpty ? null : validators.email(value),
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: l10n.mapUrl,
            hint: l10n.mapUrl,
            controller: _map,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(label: l10n.save, onPressed: _save, isLoading: isSubmitting),
        ],
      ),
    );
  }
}

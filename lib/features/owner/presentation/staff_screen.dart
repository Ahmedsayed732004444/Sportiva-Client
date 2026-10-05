import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../application/owner_controllers.dart';
import '../data/owner_club_models.dart';
import '../data/owner_club_repository.dart';

extension StaffPermissionLabels on StaffPermission {
  String label(AppLocalizations l10n) => switch (this) {
    StaffPermission.manageBookings => l10n.permManageBookings,
    StaffPermission.manualBookings => l10n.permManualBookings,
    StaffPermission.viewReports => l10n.permViewReports,
    StaffPermission.checkIn => l10n.permCheckIn,
    StaffPermission.manageSlots => l10n.permManageSlots,
    StaffPermission.ratePlayers => l10n.permRatePlayers,
    StaffPermission.tournamentResults => l10n.permTournamentResults,
    StaffPermission.editCourts => l10n.permEditCourts,
    StaffPermission.manageTournaments => l10n.permManageTournaments,
  };
}

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final staff = ref.watch(staffProvider);
    final repository = ref.read(ownerClubRepositoryProvider);

    Future<void> run(Future<void> Function() action, {String? done}) async {
      try {
        await action();
        ref.invalidate(staffProvider);
        if (context.mounted && done != null) showSnack(context, done);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    Future<void> resetPassword(StaffMember member) async {
      final validators = Validators(l10n);
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.resetPassword),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              obscureText: true,
              validator: validators.password,
              decoration: InputDecoration(hintText: l10n.newPassword),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(context, true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      );
      final password = controller.text;
      controller.dispose();
      if (saved == true) await run(() => repository.resetStaffPassword(member.id, password), done: l10n.passwordReset);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staff)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/owner/staff/new');
          ref.invalidate(staffProvider);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onBrand,
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.addStaff),
      ),
      body: staff.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(staffProvider),
        ),
        data: (members) => members.isEmpty
            ? EmptyView(message: l10n.noStaff, icon: Icons.groups_outlined)
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.s),
                children: [
                  for (final member in members)
                    Card(
                      elevation: 0,
                      color: AppColors.gray200,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(member.fullName, style: AppTextStyles.body1Semibold)),
                                Switch(
                                  value: member.isActive,
                                  activeTrackColor: AppColors.primary,
                                  onChanged: (_) => run(() => repository.toggleStaff(member.id)),
                                ),
                              ],
                            ),
                            Text(member.email, style: AppTextStyles.body2),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final p in member.permissions)
                                  Chip(
                                    label: Text(p.label(l10n), style: AppTextStyles.caption),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(onPressed: () => resetPassword(member), child: Text(l10n.resetPassword)),
                                TextButton(
                                  onPressed: () =>
                                      run(() => repository.removeStaff(member.id), done: l10n.staffRemoved),
                                  child: Text(l10n.removeStaff, style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class StaffFormScreen extends ConsumerStatefulWidget {
  const StaffFormScreen({super.key});

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _permissions = <StaffPermission>{StaffPermission.manageBookings};
  final _courts = <String>{};

  @override
  void dispose() {
    for (final controller in [_first, _last, _email, _password, _phone]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final done = await submit(
      () => ref
          .read(ownerClubRepositoryProvider)
          .addStaff(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            permissions: _permissions.toList(),
            courtIds: _courts.toList(),
          ),
    );
    if (done && mounted) {
      showMessage(context.l10n.staffAdded);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);
    final courts = ref.watch(ownerCourtsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addStaff)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            AppTextField(label: l10n.firstName, hint: l10n.firstName, controller: _first, validator: validators.name),
            const SizedBox(height: AppSpacing.m),
            AppTextField(label: l10n.lastName, hint: l10n.lastName, controller: _last, validator: validators.name),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.email,
              hint: l10n.email,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: validators.email,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.password,
              hint: l10n.enterPassword,
              controller: _password,
              isPassword: true,
              validator: validators.password,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.phone,
              hint: l10n.enterPhone,
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: (value) => (value ?? '').trim().isEmpty ? null : validators.phone(value),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.staffPermissions, style: AppTextStyles.title),
            Wrap(
              spacing: 8,
              children: [
                for (final permission in StaffPermission.values)
                  FilterChip(
                    label: Text(permission.label(l10n)),
                    selected: _permissions.contains(permission),
                    onSelected: (on) =>
                        setState(() => on ? _permissions.add(permission) : _permissions.remove(permission)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.staffCourts, style: AppTextStyles.title),
            Wrap(
              spacing: 8,
              children: [
                for (final court in courts)
                  FilterChip(
                    label: Text(court.name),
                    selected: _courts.contains(court.id),
                    onSelected: (on) => setState(() => on ? _courts.add(court.id) : _courts.remove(court.id)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(label: l10n.addStaff, onPressed: _save, isLoading: isSubmitting),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/snack.dart';
import '../../auth/application/auth_controller.dart';
import '../application/account_providers.dart';
import '../data/account_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final account = ref.watch(accountProvider).valueOrNull;

    Future<void> editPhone() async {
      final validators = Validators(l10n);
      final controller = TextEditingController(text: account?.phone);
      final formKey = GlobalKey<FormState>();
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.phone),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              validator: validators.phone,
              decoration: InputDecoration(hintText: l10n.enterPhone),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(context, true);
              },
              child: Text(l10n.savePhone),
            ),
          ],
        ),
      );
      final phone = controller.text.trim();
      controller.dispose();
      if (saved != true || account == null) return;

      try {
        await ref
            .read(accountRepositoryProvider)
            .updateProfile(firstName: account.firstName, lastName: account.lastName, phone: phone);
        ref.invalidate(accountProvider);
        if (context.mounted) showSnack(context, l10n.phoneSaved);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    Future<void> deleteAccount() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(l10n.deleteAccountBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.deleteAccountConfirm, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      try {
        await ref.read(accountRepositoryProvider).requestDeletion();
        if (context.mounted) showSnack(context, l10n.deletionRequested);
        await ref.read(authControllerProvider.notifier).signOut();
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.m,
        AppSpacing.screenPadding,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(color: AppColors.black600, fontWeight: FontWeight.w700),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          section(l10n.account),
          ListTile(
            leading: const Icon(Icons.mail_outline, color: AppColors.primary),
            title: Text(account?.email ?? '', style: AppTextStyles.body1),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
            title: Text(account?.phone ?? l10n.enterPhone, style: AppTextStyles.body1),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: account == null ? null : editPhone,
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.primary),
            title: Text(l10n.changePassword, style: AppTextStyles.body1),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/password'),
          ),
          section(l10n.settings),
          ListTile(
            leading: const Icon(Icons.translate, color: AppColors.primary),
            title: Text(l10n.language, style: AppTextStyles.body1),
            trailing: const LanguageButton(),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            title: Text(l10n.notificationSettings, style: AppTextStyles.body1),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/notifications'),
          ),
          const Divider(height: AppSpacing.xl),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(l10n.deleteAccount, style: AppTextStyles.body1.copyWith(color: AppColors.error)),
            onTap: deleteAccount,
          ),
        ],
      ),
    );
  }
}

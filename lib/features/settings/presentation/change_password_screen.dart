import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../data/account_repository.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_current, _next, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final done = await submit(() => ref.read(accountRepositoryProvider).changePassword(_current.text, _next.text));
    if (done && mounted) {
      showMessage(context.l10n.passwordChanged);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            AppTextField(
              label: l10n.currentPassword,
              hint: l10n.enterCurrentPassword,
              controller: _current,
              isPassword: true,
              validator: validators.required,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.newPassword,
              hint: l10n.enterPassword,
              controller: _next,
              isPassword: true,
              validator: validators.password,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.confirmPassword,
              hint: l10n.retypePassword,
              controller: _confirm,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (value) => value == _next.text ? null : l10n.passwordsDontMatch,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(label: l10n.updatePassword, onPressed: _save, isLoading: isSubmitting),
          ],
        ),
      ),
    );
  }
}

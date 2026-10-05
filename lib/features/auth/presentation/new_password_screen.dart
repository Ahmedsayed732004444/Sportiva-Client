import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../data/auth_repository.dart';
import 'auth_route_args.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, required this.args});

  final NewPasswordArgs args;

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    final done = await submit(
      () => ref
          .read(authRepositoryProvider)
          .resetPassword(email: widget.args.email, code: widget.args.code, newPassword: _password.text),
    );

    if (done && mounted) {
      showMessage(context.l10n.passwordUpdated);
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);

    return AuthScaffold(
      title: l10n.setNewPassword,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s),
            Text(l10n.setNewPasswordHint, style: AppTextStyles.body1.copyWith(color: AppColors.black600)),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.password,
              hint: l10n.enterPassword,
              controller: _password,
              validator: validators.password,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.confirmPassword,
              hint: l10n.retypePassword,
              controller: _confirm,
              validator: validators.matches(_password),
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _update(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(label: l10n.updatePassword, onPressed: _update, isLoading: isSubmitting),
          ],
        ),
      ),
    );
  }
}

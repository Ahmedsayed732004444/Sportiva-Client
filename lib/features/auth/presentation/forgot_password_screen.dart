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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();

    final done = await submit(() => ref.read(authRepositoryProvider).forgotPassword(email));
    if (done && mounted) {
      context.push(
        AppRoutes.otp,
        extra: OtpArgs(email: email, purpose: OtpPurpose.resetPassword),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthScaffold(
      title: l10n.forgotPasswordTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s),
            Text(l10n.forgotPasswordHint, style: AppTextStyles.body1.copyWith(color: AppColors.black600)),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.email,
              hint: l10n.enterEmail,
              controller: _email,
              validator: Validators(l10n).email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              // Rebuilds the button: it looks disabled until something is typed.
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _continue(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              label: l10n.continueLabel,
              onPressed: _email.text.trim().isEmpty ? null : _continue,
              isLoading: isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}

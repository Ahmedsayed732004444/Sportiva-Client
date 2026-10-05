import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/google_sign_in_button.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/or_divider.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';
import 'auth_route_args.dart';
import 'widgets/auth_switch_link.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();

    try {
      await submit(
        () => ref.read(authControllerProvider.notifier).signIn(email: email, password: _password.text),
        rethrowErrors: true,
      );
    } on ApiException catch (e) {
      // An unconfirmed email goes straight to the code screen with a fresh code.
      if (e.hasCode('User.EmailNotConfirmed') && mounted) {
        await ref.read(authRepositoryProvider).resendConfirmation(email);
        if (!mounted) return;
        showMessage(context.l10n.emailNotConfirmedHint);
        context.push(
          AppRoutes.otp,
          extra: OtpArgs(email: email, purpose: OtpPurpose.confirmEmail),
        );
      } else if (mounted) {
        showMessage(e.messageFor(context.l10n));
      }
    }
  }

  Future<void> _google() => submit(ref.read(authControllerProvider.notifier).signInWithGoogle);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);

    return AuthScaffold(
      centeredTitle: l10n.login,
      actions: const [LanguageButton()],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.email,
              hint: l10n.enterEmail,
              controller: _email,
              validator: validators.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.password,
              hint: l10n.enterPassword,
              controller: _password,
              validator: validators.required,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _signIn(),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: Text(l10n.forgotPassword, style: AppTextStyles.body2),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            AppButton(label: l10n.signIn, onPressed: _signIn, isLoading: isSubmitting),
            const SizedBox(height: AppSpacing.s),
            AuthSwitchLink(prompt: l10n.noAccount, action: l10n.signUpLink, onTap: () => context.go(AppRoutes.signUp)),
            const SizedBox(height: AppSpacing.xl),
            OrDivider(l10n.orLoginWith),
            const SizedBox(height: AppSpacing.s),
            Center(
              child: GoogleSignInButton(onPressed: _google, isLoading: isSubmitting),
            ),
          ],
        ),
      ),
    );
  }
}

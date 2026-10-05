import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  final _rePassword = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_email, _firstName, _lastName, _password, _rePassword]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();

    final done = await submit(
      () => ref
          .read(authRepositoryProvider)
          .register(
            email: email,
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            password: _password.text,
          ),
    );

    if (done && mounted) {
      showMessage(context.l10n.accountCreated);
      context.push(
        AppRoutes.otp,
        extra: OtpArgs(email: email, purpose: OtpPurpose.confirmEmail),
      );
    }
  }

  Future<void> _google() => submit(ref.read(authControllerProvider.notifier).signInWithGoogle);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);

    return AuthScaffold(
      centeredTitle: l10n.signUp,
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
            const SizedBox(height: AppSpacing.s),
            AppTextField(
              label: l10n.firstName,
              hint: l10n.enterFirstName,
              controller: _firstName,
              validator: validators.name,
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.givenName],
            ),
            const SizedBox(height: AppSpacing.s),
            AppTextField(
              label: l10n.lastName,
              hint: l10n.enterLastName,
              controller: _lastName,
              validator: validators.name,
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.familyName],
            ),
            const SizedBox(height: AppSpacing.s),
            AppTextField(
              label: l10n.password,
              hint: l10n.enterPassword,
              controller: _password,
              validator: validators.password,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.s),
            AppTextField(
              label: l10n.rePassword,
              hint: l10n.retypePassword,
              controller: _rePassword,
              validator: validators.matches(_password),
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _signUp(),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(label: l10n.signUp, onPressed: _signUp, isLoading: isSubmitting),
            const SizedBox(height: AppSpacing.s),
            AuthSwitchLink(prompt: l10n.haveAccount, action: l10n.signInLink, onTap: () => context.go(AppRoutes.login)),
            const SizedBox(height: AppSpacing.l),
            OrDivider(l10n.orSignUpWith),
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

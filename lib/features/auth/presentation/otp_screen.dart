import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/otp_field.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../data/auth_repository.dart';
import 'auth_route_args.dart';
import 'widgets/auth_switch_link.dart';

// The 6-digit code screen, for confirming an email after sign-up and for resetting a password.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});

  final OtpArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with SubmitMixin {
  static const _length = 6;
  // The API sends one code per minute.
  static const _resendSeconds = 60;

  final _code = TextEditingController();
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    final repository = ref.read(authRepositoryProvider);
    final email = widget.args.email;

    final done = await submit(
      () => switch (widget.args.purpose) {
        OtpPurpose.confirmEmail => repository.resendConfirmation(email),
        OtpPurpose.resetPassword => repository.forgotPassword(email),
      },
    );

    if (done && mounted) {
      _startCountdown();
      showMessage(context.l10n.codeResent);
    }
  }

  Future<void> _verify() async {
    final code = _code.text;
    if (code.length != _length) return;

    switch (widget.args.purpose) {
      // The API checks the code together with the new password on the next screen.
      case OtpPurpose.resetPassword:
        context.push(
          AppRoutes.newPassword,
          extra: NewPasswordArgs(email: widget.args.email, code: code),
        );
      case OtpPurpose.confirmEmail:
        final done = await submit(
          () => ref.read(authRepositoryProvider).confirmEmail(email: widget.args.email, code: code),
        );
        if (done && mounted) {
          showMessage(context.l10n.emailConfirmed);
          context.go(AppRoutes.login);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canVerify = _code.text.length == _length;

    return AuthScaffold(
      title: l10n.checkYourEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s),
          Text.rich(
            TextSpan(
              style: AppTextStyles.body1.copyWith(color: AppColors.black600),
              children: [
                TextSpan(text: '${l10n.codeSentTo} '),
                TextSpan(
                  text: widget.args.email,
                  style: TextStyle(color: AppColors.primaryMid),
                ),
                TextSpan(text: '\n${l10n.enterCodeHint}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          OtpField(controller: _code, length: _length, onChanged: (_) => setState(() {})),
          const SizedBox(height: AppSpacing.l),
          AppButton(label: l10n.verifyCode, onPressed: canVerify ? _verify : null, isLoading: isSubmitting),
          const SizedBox(height: AppSpacing.s),
          if (_secondsLeft > 0)
            Text(
              l10n.resendIn(_secondsLeft),
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(color: AppColors.black600),
            )
          else
            AuthSwitchLink(prompt: l10n.noEmailYet, action: l10n.resendEmail, onTap: _resend, underline: true),
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// "Don't have an account? Sign up": plain text with a colored tappable part.
class AuthSwitchLink extends StatefulWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
    this.underline = false,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;
  final bool underline;

  @override
  State<AuthSwitchLink> createState() => _AuthSwitchLinkState();
}

class _AuthSwitchLinkState extends State<AuthSwitchLink> {
  late final _recognizer = TapGestureRecognizer()..onTap = widget.onTap;

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: AppTextStyles.body1,
        children: [
          TextSpan(text: '${widget.prompt} '),
          TextSpan(
            text: widget.action,
            recognizer: _recognizer,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.primaryMid,
              decoration: widget.underline ? TextDecoration.underline : null,
              decorationColor: AppColors.primaryMid,
            ),
          ),
        ],
      ),
    );
  }
}

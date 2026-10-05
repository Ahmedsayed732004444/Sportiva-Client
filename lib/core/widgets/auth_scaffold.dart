import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// Shared frame of every auth screen: optional back arrow with a title, then scrollable padded content that stays above the keyboard.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.title, this.centeredTitle, this.actions});

  // A title next to the back arrow (the inner pages), or a big centered one (login / sign up).
  final String? title;
  final String? centeredTitle;
  final List<Widget>? actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null && actions == null
          ? null
          : AppBar(title: title == null ? null : Text(title!), actions: actions),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.s,
            AppSpacing.screenPadding,
            AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (centeredTitle != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  centeredTitle!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.header.copyWith(color: const Color(0xFF2A7F62)),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

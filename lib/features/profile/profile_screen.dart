import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/application/auth_controller.dart';
import '../notifications/presentation/notification_bell.dart';
import '../settings/application/account_providers.dart';

// Who you are and the doors to everything personal: your profile, teams, ratings, messages, settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(authControllerProvider).valueOrNull;
    final managesClub = ref.watch(managesClubProvider);

    Widget tile(IconData icon, String title, String route) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile), actions: const [NotificationBell()]),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.m),
          Center(child: UserAvatar(name: session?.fullName ?? '', radius: 40)),
          const SizedBox(height: AppSpacing.s),
          Text(session?.fullName ?? '', textAlign: TextAlign.center, style: AppTextStyles.header),
          Text(
            session?.email ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(color: AppColors.black600),
          ),
          const SizedBox(height: AppSpacing.l),
          if (managesClub) tile(Icons.storefront_outlined, l10n.manageClub, '/owner'),
          if (session != null) tile(Icons.person_outline, l10n.viewProfile, '/user/${session.userId}'),
          tile(Icons.bookmark_border, l10n.savedPosts, '/saved'),
          tile(Icons.emoji_events_outlined, l10n.teamsAndInvitations, '/tournaments/mine'),
          tile(Icons.star_border_rounded, l10n.myReviews, '/reviews'),
          tile(Icons.chat_bubble_outline, l10n.messages, '/messages'),
          tile(Icons.settings_outlined, l10n.settings, '/settings'),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: l10n.signOut,
            onPressed: ref.read(authControllerProvider.notifier).signOut,
            style: AppButtonStyle.outlined,
          ),
        ],
      ),
    );
  }
}

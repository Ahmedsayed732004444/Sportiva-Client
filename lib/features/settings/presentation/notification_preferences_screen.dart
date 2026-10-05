import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../data/account_repository.dart';

enum _Category {
  bookings,
  payments,
  matches,
  social,
  tournaments,
  account;

  static const _socialTypes = {
    'NewFollower',
    'PostLiked',
    'PostCommented',
    'CommentReplied',
    'CommentLiked',
    'NewMessage',
    'PostPublished',
    'PostFailed',
  };

  // The API has one preference per notification type; the screen groups them by what they are about.
  static _Category of(String type) {
    if (type.startsWith('Booking') || type.startsWith('RecurringBooking') || type == 'ReviewRequested') return bookings;
    if (type.startsWith('Payment') || type.startsWith('Subscription')) return payments;
    if (type.startsWith('Match')) return matches;
    if (_socialTypes.contains(type)) return social;
    if (type.startsWith('Tournament')) return tournaments;
    return account;
  }

  String label(AppLocalizations l10n) => switch (this) {
    bookings => l10n.categoryBookings,
    payments => l10n.categoryPayments,
    matches => l10n.categoryMatches,
    social => l10n.categorySocial,
    tournaments => l10n.categoryTournaments,
    account => l10n.categoryAccount,
  };
}

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  List<NotificationPreference>? _preferences;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final loaded = await ref.read(accountRepositoryProvider).notificationPreferences();
      if (mounted) setState(() => _preferences = loaded);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  bool _all(_Category category, bool Function(NotificationPreference) channel) =>
      _preferences!.where((p) => _Category.of(p.type) == category).every(channel);

  // Switching a group switches every type in it, and saves.
  Future<void> _set(_Category category, {bool? inApp, bool? email}) async {
    final before = _preferences!;
    setState(
      () => _preferences = [
        for (final p in before) _Category.of(p.type) == category ? p.copyWith(inApp: inApp, email: email) : p,
      ],
    );

    try {
      await ref.read(accountRepositoryProvider).saveNotificationPreferences(_preferences!);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _preferences = before);
      showApiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preferences = _preferences;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: preferences == null
          ? (_error == null ? const LoadingView() : ErrorView(error: _error!, onRetry: _load))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.s),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      SizedBox(
                        width: 72,
                        child: Text(
                          l10n.inApp,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: Text(
                          l10n.byEmail,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final category in _Category.values)
                  if (preferences.any((p) => _Category.of(p.type) == category))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                      child: Row(
                        children: [
                          Expanded(child: Text(category.label(l10n), style: AppTextStyles.body1)),
                          SizedBox(
                            width: 72,
                            child: Switch(
                              value: _all(category, (p) => p.inApp),
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) => _set(category, inApp: value),
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Switch(
                              value: _all(category, (p) => p.email),
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) => _set(category, email: value),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
    );
  }
}

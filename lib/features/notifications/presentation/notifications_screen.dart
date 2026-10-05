import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../application/notification_routes.dart';
import '../application/notifications_controller.dart';
import '../data/app_notification.dart';
import 'notification_icons.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasUnread = ref.watch(unreadCountProvider) > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (hasUnread)
            TextButton(onPressed: ref.read(notificationsProvider.notifier).markAllRead, child: Text(l10n.markAllRead)),
        ],
      ),
      body: PagedListView<AppNotification>(
        state: notificationsProvider,
        actions: notificationsProvider.notifier,
        emptyMessage: l10n.noNotifications,
        emptyIcon: Icons.notifications_none,
        padding: EdgeInsets.zero,
        separator: Divider(height: 1, color: AppColors.gray200),
        itemBuilder: (context, notification) => _NotificationTile(notification: notification),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(notificationsProvider.notifier);

    return Dismissible(
      key: ValueKey(notification.id),
      onDismissed: (_) => controller.remove(notification),
      background: Container(
        color: AppColors.error,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: Icon(Icons.delete_outline, color: AppColors.surface),
      ),
      child: InkWell(
        onTap: () {
          controller.open(notification);
          final route = notificationRoute(notification);
          if (route != null) context.push(route);
        },
        child: Container(
          color: notification.isRead ? AppColors.surface : AppColors.primaryLight.withValues(alpha: 0.12),
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(notificationIcon(notification.type), color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: notification.isRead ? AppTextStyles.body1 : AppTextStyles.body1Semibold,
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
                    const SizedBox(height: 4),
                    Text(
                      relativeTime(context.l10n, notification.createdAt),
                      style: AppTextStyles.small.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../application/bookings_controller.dart';
import '../data/booking_models.dart';
import 'widgets/booking_status_chip.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navBookings),
          actions: const [NotificationBell()],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.black600,
            indicatorColor: AppColors.primary,
            labelStyle: AppTextStyles.body1Semibold,
            unselectedLabelStyle: AppTextStyles.body1,
            tabs: [
              Tab(text: l10n.upcoming),
              Tab(text: l10n.past),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PagedListView<Booking>(
              state: upcomingBookingsProvider,
              actions: upcomingBookingsProvider.notifier,
              emptyMessage: l10n.noBookings,
              emptyIcon: Icons.event_busy_outlined,
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, booking) => BookingCard(booking: booking),
            ),
            PagedListView<Booking>(
              state: pastBookingsProvider,
              actions: pastBookingsProvider.notifier,
              emptyMessage: l10n.noBookings,
              emptyIcon: Icons.event_busy_outlined,
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, booking) => BookingCard(booking: booking),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    return AppCard(
      onTap: () => context.push('/booking/${booking.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(booking.sport.icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.courtName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body1Semibold,
                  ),
                  Text(
                    booking.club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(color: AppColors.black600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDay(locale, parseApiDay(booking.day))} · ${l10n.timeRange(formatTime(locale, booking.startTime), formatTime(locale, booking.endTime))}',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BookingStatusChip(booking.status),
                const SizedBox(height: 6),
                Text(
                  l10n.priceTotal(formatPounds(booking.pricePiasters)),
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

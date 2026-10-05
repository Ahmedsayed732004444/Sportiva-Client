import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/snack.dart';
import '../../booking/data/booking_models.dart';
import '../../booking/presentation/booking_labels.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/presentation/rating_sheet.dart';
import '../application/owner_controllers.dart';
import '../data/owner_booking_repository.dart';

class OwnerBookingsTab extends StatelessWidget {
  const OwnerBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/owner/bookings/new'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.add),
          label: Text(l10n.manualBooking),
        ),
        body: Column(
          children: [
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.black600,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: l10n.tabPending),
                Tab(text: l10n.tabUpcoming),
                Tab(text: l10n.tabPast),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PagedListView<Booking>(
                    state: pendingOwnerBookingsProvider,
                    actions: pendingOwnerBookingsProvider.notifier,
                    emptyMessage: l10n.noOwnerBookings,
                    emptyIcon: Icons.event_busy_outlined,
                    separator: const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, booking) => _OwnerBookingCard(booking: booking),
                  ),
                  PagedListView<Booking>(
                    state: upcomingOwnerBookingsProvider,
                    actions: upcomingOwnerBookingsProvider.notifier,
                    emptyMessage: l10n.noOwnerBookings,
                    emptyIcon: Icons.event_busy_outlined,
                    separator: const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, booking) => _OwnerBookingCard(booking: booking),
                  ),
                  PagedListView<Booking>(
                    state: pastOwnerBookingsProvider,
                    actions: pastOwnerBookingsProvider.notifier,
                    emptyMessage: l10n.noOwnerBookings,
                    emptyIcon: Icons.event_busy_outlined,
                    separator: const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, booking) => _OwnerBookingCard(booking: booking),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerBookingCard extends ConsumerStatefulWidget {
  const _OwnerBookingCard({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_OwnerBookingCard> createState() => _OwnerBookingCardState();
}

class _OwnerBookingCardState extends ConsumerState<_OwnerBookingCard> {
  bool _busy = false;

  Booking get booking => widget.booking;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(pendingOwnerBookingsProvider);
      ref.invalidate(upcomingOwnerBookingsProvider);
      ref.invalidate(pastOwnerBookingsProvider);
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Rejecting and cancelling ask for an optional reason that the customer will see.
  Future<void> _withReason(String title, Future<void> Function(String? reason) action) async {
    final l10n = context.l10n;
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: reason,
          decoration: InputDecoration(hintText: l10n.reasonOptional),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(title, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (confirmed == true) await _run(() => action(text.isEmpty ? null : text));
  }

  Future<void> _ratePlayer() async {
    final l10n = context.l10n;
    final sent = await showRatingSheet(
      context,
      title: booking.customerName ?? l10n.customer,
      submit: (rating, comment) => ref.read(reviewRepositoryProvider).rateBookingPlayer(booking.id, rating, comment),
    );
    if (!sent || !mounted) return;
    showSnack(context, l10n.reviewSent);
    ref.invalidate(pastOwnerBookingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final repository = ref.read(ownerBookingRepositoryProvider);
    final deadline = booking.responseDeadlineUtc?.toLocal();

    Widget action(String label, VoidCallback onPressed, {bool danger = false}) => TextButton(
      onPressed: _busy ? null : onPressed,
      child: Text(label, style: TextStyle(color: danger ? AppColors.error : AppColors.primary)),
    );

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatDay(locale, parseApiDay(booking.day))} · ${l10n.timeRange(formatTime(locale, booking.startTime), formatTime(locale, booking.endTime))}',
                    style: AppTextStyles.body1Semibold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.label(l10n),
                    style: AppTextStyles.caption.copyWith(color: booking.status.color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.courtName} · ${l10n.priceTotal(formatPounds(booking.pricePiasters))}',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: AppColors.black600),
                const SizedBox(width: 4),
                Flexible(child: Text(booking.customerName ?? l10n.walkInCustomer, style: AppTextStyles.body1)),
                const SizedBox(width: AppSpacing.xs),
                RatingBadge(rating: booking.customerRating, count: booking.customerReviewsCount),
                const Spacer(),
                if (booking.customerPhone?.isNotEmpty ?? false)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.callCustomer,
                    icon: const Icon(Icons.call_outlined, color: AppColors.primary),
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: booking.customerPhone)),
                  ),
              ],
            ),
            if (booking.canRespond && deadline != null)
              Text(
                l10n.needsReply(
                  formatTime(
                    locale,
                    '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}:00',
                  ),
                ),
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryMid),
              ),
            Wrap(
              children: [
                if (booking.canRespond) action(l10n.confirmAction, () => _run(() => repository.confirm(booking.id))),
                if (booking.canRespond)
                  action(
                    l10n.rejectAction,
                    () => _withReason(l10n.rejectBookingTitle, (reason) => repository.reject(booking.id, reason)),
                    danger: true,
                  ),
                if (booking.canComplete) action(l10n.markCompleted, () => _run(() => repository.complete(booking.id))),
                if (booking.canMarkNoShow)
                  action(l10n.markNoShow, () => _run(() => repository.markNoShow(booking.id)), danger: true),
                if (booking.canRatePlayer) action(l10n.ratePlayer, _ratePlayer),
                if (booking.canCancel)
                  action(
                    l10n.cancelBookingAction,
                    () => _withReason(l10n.cancelBookingAction, (reason) => repository.cancel(booking.id, reason)),
                    danger: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

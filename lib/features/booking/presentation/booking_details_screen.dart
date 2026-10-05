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
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/stepper_field.dart';
import '../../matches/data/match_repository.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/presentation/rating_sheet.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/bookings_controller.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';
import 'widgets/booking_status_chip.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bookingDetails)),
      body: booking.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(bookingProvider(bookingId)),
        ),
        data: (booking) => _Details(booking: booking),
      ),
    );
  }
}

class _Details extends ConsumerStatefulWidget {
  const _Details({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_Details> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<_Details> with SubmitMixin {
  Booking get booking => widget.booking;

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final reason = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelBooking),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.cancelBookingBody),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: reason,
              decoration: InputDecoration(hintText: l10n.cancelReasonHint),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.keepBooking)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cancelBooking, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (confirmed != true || !mounted) return;

    final done = await submit(() => ref.read(bookingRepositoryProvider).cancel(booking.id, text.isEmpty ? null : text));
    if (done && mounted) {
      showMessage(l10n.bookingCancelled);
      ref.invalidate(bookingProvider(booking.id));
    }
  }

  Future<void> _openMatch() async {
    final l10n = context.l10n;
    var players = 3;
    final note = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.openMatchFromBooking),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.playersToFind),
              const SizedBox(height: AppSpacing.s),
              StepperField(value: players, onChanged: (v) => setState(() => players = v)),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: note,
                decoration: InputDecoration(hintText: l10n.enterNote),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.openMatch)),
          ],
        ),
      ),
    );
    final text = note.text.trim();
    note.dispose();
    if (confirmed != true || !mounted) return;

    String? matchId;
    final done = await submit(() async {
      matchId =
          (await ref
                  .read(matchRepositoryProvider)
                  .openFromBooking(booking.id, playersNeeded: players, note: text.isEmpty ? null : text))
              .id;
    });
    if (done && mounted) context.push('/match/$matchId');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body1Semibold)),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.bookingCode(booking.code), style: AppTextStyles.header)),
            BookingStatusChip(booking.status),
          ],
        ),
        if (booking.status == BookingStatus.pending)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(l10n.waitingForClub, style: AppTextStyles.body2.copyWith(color: AppColors.primaryMid)),
          ),
        const SizedBox(height: AppSpacing.m),
        row(l10n.club, booking.club.name),
        row(l10n.court, '${booking.courtName} · ${booking.sport.label(l10n)}'),
        row(l10n.dateLabel, formatLongDay(locale, parseApiDay(booking.day))),
        row(l10n.timeLabel, l10n.timeRange(formatTime(locale, booking.startTime), formatTime(locale, booking.endTime))),
        row(l10n.duration, l10n.minutesLabel(booking.durationMinutes)),
        row(l10n.total, l10n.priceTotal(formatPounds(booking.pricePiasters))),
        if (booking.rejectionReason != null) row(l10n.reason, booking.rejectionReason!),
        if (booking.cancellationReason != null) row(l10n.reason, booking.cancellationReason!),
        const SizedBox(height: AppSpacing.l),
        if (booking.clubPhone.isNotEmpty)
          AppButton(
            label: l10n.callClub,
            style: AppButtonStyle.outlined,
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: booking.clubPhone)),
          ),
        if (booking.canReview) ...[
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: l10n.rateCourt,
            style: AppButtonStyle.outlined,
            onPressed: () async {
              final sent = await showRatingSheet(
                context,
                title: '${booking.club.name} - ${booking.courtName}',
                submit: (rating, comment) =>
                    ref.read(reviewRepositoryProvider).rateBooking(booking.id, rating, comment),
              );
              if (sent && mounted) {
                showMessage(l10n.reviewSent);
                ref.invalidate(bookingProvider(booking.id));
              }
            },
          ),
        ],
        if (booking.matchId != null) ...[
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: l10n.matchDetails,
            style: AppButtonStyle.outlined,
            onPressed: () => context.push('/match/${booking.matchId}'),
          ),
        ] else if (booking.canOpenMatch) ...[
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: l10n.openMatchFromBooking,
            style: AppButtonStyle.outlined,
            isLoading: isSubmitting,
            onPressed: _openMatch,
          ),
        ],
        if (booking.canCancel) ...[
          const SizedBox(height: AppSpacing.s),
          AppButton(label: l10n.cancelBooking, onPressed: _cancel, isLoading: isSubmitting),
        ],
      ],
    );
  }
}

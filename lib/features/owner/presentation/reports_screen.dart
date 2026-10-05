import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../booking/presentation/recurring_labels.dart';
import '../data/owner_club_repository.dart';
import '../data/report_models.dart';

final _reportDaysProvider = StateProvider.autoDispose<int>((ref) => 30);

final _reportProvider = FutureProvider.autoDispose<ClubReport>((ref) {
  final days = ref.watch(_reportDaysProvider);
  final to = today();
  return ref
      .read(ownerClubRepositoryProvider)
      .report(
        from: to.subtract(Duration(days: days - 1)),
        to: to,
      );
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final days = ref.watch(_reportDaysProvider);
    final report = ref.watch(_reportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          ChoiceChips<int>(
            options: const [7, 30, 90],
            selected: days,
            labelOf: (d) => switch (d) {
              7 => l10n.reportPeriod7,
              30 => l10n.reportPeriod30,
              _ => l10n.reportPeriod90,
            },
            onSelected: (d) => ref.read(_reportDaysProvider.notifier).state = d,
          ),
          const SizedBox(height: AppSpacing.m),
          report.when(
            loading: () => const SizedBox(height: 240, child: LoadingView()),
            error: (error, _) => ErrorView(
              error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
              onRetry: () => ref.invalidate(_reportProvider),
            ),
            data: (report) => _Body(report: report),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report});

  final ClubReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.xs),
      child: Text(text, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
    );

    Widget stat(String label, String value, {Color? color}) => Expanded(
      child: Card(
        elevation: 0,
        color: AppColors.gray200,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.header.copyWith(color: color ?? AppColors.black)),
            ],
          ),
        ),
      ),
    );

    final peaks = [...report.peakHours]..sort((a, b) => b.bookedHours.compareTo(a.bookedHours));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            stat(l10n.revenue, l10n.feeAmount(formatPounds(report.revenuePiasters)), color: AppColors.primary),
            stat(l10n.bookingsTotal, '${report.total}'),
          ],
        ),
        Row(
          children: [
            stat(l10n.statusCompleted, '${report.completed}'),
            stat(l10n.statusCancelled, '${report.cancelled}'),
            stat(l10n.noShowRate, '${(report.noShowRate * 100).round()}%'),
          ],
        ),
        if (report.occupancy.isNotEmpty) ...[
          heading(l10n.occupancy),
          for (final court in report.occupancy)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(court.name, style: AppTextStyles.body1)),
                      Text(
                        l10n.hoursBooked(court.bookedHours.toStringAsFixed(1), court.availableHours.toStringAsFixed(0)),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: court.rate.clamp(0, 1),
                    minHeight: 8,
                    color: AppColors.primary,
                    backgroundColor: AppColors.gray200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
        ],
        if (peaks.isNotEmpty) ...[
          heading(l10n.peakHours),
          for (final peak in peaks.take(5))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_fire_department_outlined, color: AppColors.primary),
              title: Text(
                '${weekdayName(l10n, peak.dayOfWeek)} · ${formatTime(locale, '${peak.hour.toString().padLeft(2, '0')}:00:00')}',
              ),
              trailing: Text('${peak.bookedHours.toStringAsFixed(1)}h'),
            ),
        ],
        if (report.sources.isNotEmpty) ...[
          heading(l10n.bySource),
          for (final source in report.sources)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(switch (source.source) {
                'App' => l10n.sourceApp,
                'Manual' => l10n.sourceManual,
                'Recurring' => l10n.tabWeekly,
                _ => l10n.ownerTournaments,
              }),
              subtitle: Text('${source.count}'),
              trailing: Text(l10n.feeAmount(formatPounds(source.revenuePiasters))),
            ),
        ],
        if (report.topCustomers.isNotEmpty) ...[
          heading(l10n.topCustomers),
          for (final customer in report.topCustomers)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(customer.name),
              subtitle: customer.phone == null ? null : Text(customer.phone!),
              trailing: Text('${customer.count}'),
            ),
        ],
        heading(l10n.ratingsSummary),
        RatingBadge(rating: report.averageRating, count: report.reviewsCount),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/localization/date_time_format.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/recurring_models.dart';
import '../recurring_labels.dart';

// A weekly booking; [actions] are the buttons under it (cancel for the player, confirm / reject for the club).
class RecurringCard extends StatelessWidget {
  const RecurringCard({super.key, required this.booking, this.actions = const [], this.showCustomer = false});

  final RecurringBooking booking;
  final List<Widget> actions;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

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
                    '${l10n.everyWeekDay(weekdayName(l10n, booking.dayOfWeek))} · ${formatTime(locale, booking.startTime)}',
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
            Text('${booking.club.name} · ${booking.courtName}', style: AppTextStyles.body2),
            Text(
              l10n.weeksOf(booking.weeks, formatDay(locale, parseApiDay(booking.firstDay))),
              style: AppTextStyles.caption.copyWith(color: AppColors.black600),
            ),
            if (showCustomer && booking.customerName != null) Text(booking.customerName!, style: AppTextStyles.body2),
            if (actions.isNotEmpty) Wrap(children: actions),
          ],
        ),
      ),
    );
  }
}

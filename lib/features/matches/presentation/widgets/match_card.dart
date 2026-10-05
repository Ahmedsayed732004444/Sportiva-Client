import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/date_time_format.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/match_models.dart';
import '../match_labels.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match});

  final FriendlyMatch match;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    return AppCard(
      onTap: () => context.push('/match/${match.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(match.sport.icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body1Semibold),
                  Text(
                    '${formatDay(locale, parseApiDay(match.day))} · ${l10n.timeRange(formatTime(locale, match.startTime), formatTime(locale, match.endTime))}',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 4),
                  Text(match.organizer.fullName, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: match.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    match.status.label(l10n),
                    style: AppTextStyles.caption.copyWith(color: match.status.color, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.playersCount(match.acceptedPlayers, match.playersNeeded), style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

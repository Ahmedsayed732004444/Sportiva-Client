import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/date_time_format.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/user_avatar.dart';
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
                  Row(
                    children: [
                      _Faces(players: match.participants),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          match.organizer.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                        ),
                      ),
                    ],
                  ),
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

// The first three people in the match as small overlapping faces, and how many more there are.
class _Faces extends StatelessWidget {
  const _Faces({required this.players});

  final List<MatchPlayer> players;

  static const _shown = 3;
  static const _radius = 12.0;
  static const _step = 18.0;

  @override
  Widget build(BuildContext context) {
    final first = players.take(_shown).toList();
    final more = players.length - first.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _step * (first.length - 1) + _radius * 2,
          height: _radius * 2,
          child: Stack(
            children: [
              for (var i = 0; i < first.length; i++)
                PositionedDirectional(
                  start: i * _step,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                    child: UserAvatar(name: first[i].fullName, url: first[i].avatarUrl, radius: _radius),
                  ),
                ),
            ],
          ),
        ),
        if (more > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Text(context.l10n.morePlayers(more), style: AppTextStyles.caption),
          ),
      ],
    );
  }
}

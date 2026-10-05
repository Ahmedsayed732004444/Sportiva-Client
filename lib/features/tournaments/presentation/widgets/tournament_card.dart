import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/date_time_format.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/tournament_models.dart';
import '../tournament_labels.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({super.key, required this.tournament, this.route});

  final TournamentListItem tournament;
  // Where it opens; the public page unless the club's management page asks otherwise.
  final String? route;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    return AppCard(
      onTap: () => context.push(route ?? '/tournament/${tournament.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(url: tournament.posterUrl, icon: Icons.emoji_events_outlined),
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: tournament.status.color, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      tournament.status.label(l10n),
                      style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  tournament.club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2.copyWith(color: AppColors.black600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: 4,
                  children: [
                    _Fact(tournament.sport.icon, tournament.sport.label(l10n)),
                    _Fact(
                      Icons.account_tree_outlined,
                      tournament.isIndividual ? l10n.individualTournament : tournament.format.label(l10n),
                    ),
                    _Fact(Icons.groups_outlined, l10n.teamsCount(tournament.approvedTeams, tournament.maxTeams)),
                    _Fact(Icons.payments_outlined, feeLabel(l10n, tournament.feePiasters)),
                    _Fact(Icons.event_outlined, formatDay(locale, parseApiDay(tournament.startDate))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 4),
      Text(text, style: AppTextStyles.caption),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/presentation/rating_sheet.dart';
import '../application/tournament_controllers.dart';
import '../data/tournament_models.dart';

String _stageTitle(AppLocalizations l10n, TournamentMatch match) => switch (match.stage) {
  TournamentStage.league => l10n.stageLeague,
  TournamentStage.group => l10n.stageGroup(match.groupNumber ?? 0),
  TournamentStage.knockout => l10n.stageKnockout,
};

class TournamentMatchesTab extends ConsumerWidget {
  const TournamentMatchesTab({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final matches = ref.watch(tournamentMatchesProvider(tournamentId));

    return matches.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(tournamentMatchesProvider(tournamentId)),
      ),
      data: (matches) {
        if (matches.isEmpty) return EmptyView(message: l10n.noMatchesYet, icon: Icons.sports_score_outlined);

        // "Stage / group", then the round: a heading each time either changes.
        final children = <Widget>[];
        String? lastHeading;
        for (final match in matches) {
          final heading = '${_stageTitle(l10n, match)} · ${l10n.roundLabel(match.round)}';
          if (heading != lastHeading) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.xs),
                child: Text(heading, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              ),
            );
            lastHeading = heading;
          }
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _MatchTile(match: match, tournamentId: tournamentId),
            ),
          );
        }

        return ListView(padding: const EdgeInsets.all(AppSpacing.s), children: children);
      },
    );
  }
}

class _MatchTile extends ConsumerWidget {
  const _MatchTile({required this.match, required this.tournamentId});

  final TournamentMatch match;
  final String tournamentId;

  // After a played match, its players rate each other: tapping the match opens the list of the other players.
  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    final me = ref.read(authControllerProvider).valueOrNull?.userId;
    final teams = await ref.read(tournamentTeamsProvider(tournamentId).future);
    final played = teams.where((t) => t.id == match.home?.id || t.id == match.away?.id);
    final players = {
      for (final team in played)
        for (final member in team.members.where((m) => m.status == MemberStatus.accepted))
          member.player.userId: member.player,
    };
    if (me == null || !players.containsKey(me) || !context.mounted) return;

    await showPlayersRatingSheet(
      context,
      players: [
        for (final player in players.values)
          if (player.userId != me) player,
      ],
      submit: (playerId, rating, comment) =>
          ref.read(reviewRepositoryProvider).rateTournamentPlayer(match.id, playerId, rating, comment),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final done = match.status == TournamentMatchStatus.completed;

    Widget team(TeamSummary? team, {required bool won}) => Text(
      team?.name ?? (match.isBye ? l10n.bye : l10n.tbd),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.body1Semibold.copyWith(
        color: team == null ? AppColors.gray500 : AppColors.black,
        fontWeight: won ? FontWeight.w800 : FontWeight.w600,
      ),
    );

    final when = match.day == null
        ? null
        : [
            formatDay(locale, parseApiDay(match.day!)),
            if (match.startTime != null) formatTime(locale, match.startTime!),
            if (match.courtName != null) match.courtName!,
          ].join(' · ');

    return AppCard(
      onTap: done && !match.isBye ? () => _rate(context, ref) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: team(match.home, won: done && match.winnerTeamId == match.home?.id)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                  child: Text(
                    done ? '${match.homeScore ?? 0} - ${match.awayScore ?? 0}' : 'vs',
                    style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
                Expanded(child: team(match.away, won: done && match.winnerTeamId == match.away?.id)),
              ],
            ),
            if (when != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(when, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
              ),
            if (match.resultNote?.isNotEmpty ?? false) Text(match.resultNote!, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class TournamentStandingsTab extends ConsumerWidget {
  const TournamentStandingsTab({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final standings = ref.watch(tournamentStandingsProvider(tournamentId));

    return standings.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(tournamentStandingsProvider(tournamentId)),
      ),
      data: (groups) {
        if (groups.isEmpty || groups.every((g) => g.rows.isEmpty)) {
          return EmptyView(message: l10n.noStandings, icon: Icons.leaderboard_outlined);
        }

        Widget cell(String text, {double width = 34, bool bold = false}) => SizedBox(
          width: width,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(fontWeight: bold ? FontWeight.w800 : FontWeight.w500),
          ),
        );

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.s),
          children: [
            for (final group in groups) ...[
              if (group.groupNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.xs),
                  child: Text(
                    l10n.groupNumber(group.groupNumber!),
                    style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              Row(
                children: [
                  cell('#', width: 28),
                  Expanded(child: Text('', style: AppTextStyles.caption)),
                  cell(l10n.colPlayed),
                  cell(l10n.colWon),
                  cell(l10n.colDrawn),
                  cell(l10n.colLost),
                  cell(l10n.colGoalDiff, width: 40),
                  cell(l10n.colPoints, width: 40, bold: true),
                ],
              ),
              const Divider(height: 8),
              for (final row in group.rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      cell('${row.rank}', width: 28),
                      Expanded(
                        child: Text(
                          row.team.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body1,
                        ),
                      ),
                      cell('${row.played}'),
                      cell('${row.won}'),
                      cell('${row.drawn}'),
                      cell('${row.lost}'),
                      cell('${row.goalDifference}', width: 40),
                      cell('${row.points}', width: 40, bold: true),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

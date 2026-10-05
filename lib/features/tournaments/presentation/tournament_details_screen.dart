import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/tournament_controllers.dart';
import '../data/tournament_models.dart';
import '../data/tournament_repository.dart';
import 'tournament_labels.dart';
import 'tournament_matches_tab.dart';

class TournamentDetailsScreen extends ConsumerWidget {
  const TournamentDetailsScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tournament = ref.watch(tournamentProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(title: Text(tournament.valueOrNull?.item.name ?? l10n.tournamentDetails)),
      body: tournament.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(tournamentProvider(tournamentId)),
        ),
        data: (tournament) => DefaultTabController(
          length: 4,
          child: Column(
            children: [
              _Header(tournament: tournament),
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.black600,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: l10n.tabInfo),
                  Tab(text: l10n.tabTeams),
                  Tab(text: l10n.tabMatches),
                  Tab(text: l10n.tabStandings),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _InfoTab(tournament: tournament),
                    _TeamsTab(tournamentId: tournament.id),
                    TournamentMatchesTab(tournamentId: tournament.id),
                    TournamentStandingsTab(tournamentId: tournament.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header({required this.tournament});

  final Tournament tournament;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _busy = false;

  Future<void> _register() async {
    final l10n = context.l10n;
    final tournament = widget.tournament;
    String? name;

    if (!tournament.item.isIndividual) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.registerTeam),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.teamName, hintText: l10n.enterTeamName),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.registerTeam)),
          ],
        ),
      );
      name = controller.text.trim();
      controller.dispose();
      if (confirmed != true || !mounted) return;
      if (name.isEmpty) {
        showSnack(context, l10n.enterTeamName);
        return;
      }
    }

    setState(() => _busy = true);
    try {
      final team = await ref.read(tournamentRepositoryProvider).createTeam(tournament.id, name: name);
      ref.invalidate(tournamentProvider(tournament.id));
      ref.invalidate(myTeamsProvider);
      if (!mounted) return;
      showSnack(context, l10n.teamCreated);
      context.push('/team/${team.id}');
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tournament = widget.tournament;

    return Column(
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: AppNetworkImage(url: tournament.item.posterUrl, icon: Icons.emoji_events_outlined),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    Chip(
                      label: Text(
                        tournament.status.label(l10n),
                        style: AppTextStyles.caption.copyWith(color: AppColors.onBrand),
                      ),
                      backgroundColor: tournament.status.color,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(l10n.teamsCount(tournament.item.approvedTeams, tournament.item.maxTeams)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              if (tournament.myTeamId != null)
                SizedBox(
                  width: 140,
                  child: AppButton(
                    label: l10n.myTeam,
                    style: AppButtonStyle.outlined,
                    onPressed: () => context.push('/team/${tournament.myTeamId}'),
                  ),
                )
              else if (tournament.canRegister)
                SizedBox(
                  width: 160,
                  child: AppButton(
                    label: tournament.item.isIndividual ? l10n.registerPlayer : l10n.registerTeam,
                    isLoading: _busy,
                    onPressed: _register,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final item = tournament.item;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body1Semibold)),
        ],
      ),
    );

    Widget section(String title, String? text) => text == null || text.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(text, style: AppTextStyles.body1),
              ],
            ),
          );

    final closes = tournament.registrationClosesAt.toLocal();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        if (tournament.status == TournamentStatus.cancelled)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Text(
              l10n.cancellationReason(tournament.cancellationReason ?? ''),
              style: AppTextStyles.body1.copyWith(color: AppColors.error),
            ),
          ),
        if (tournament.champion != null)
          Card(
            color: AppColors.primary.withValues(alpha: 0.08),
            elevation: 0,
            child: ListTile(
              leading: Icon(Icons.emoji_events, color: AppColors.primary),
              title: Text(l10n.champion, style: AppTextStyles.caption),
              subtitle: Text(
                tournament.champion!.name,
                style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        row(l10n.club, item.club.name),
        row(l10n.sport, item.sport.label(l10n)),
        row(l10n.tournamentFormat, item.isIndividual ? l10n.individualTournament : item.format.label(l10n)),
        if (!item.isIndividual)
          row(l10n.teamSize, l10n.teamSizeValue(tournament.playersPerTeam, tournament.substitutesPerTeam)),
        row(l10n.entryFee, feeLabel(l10n, item.feePiasters)),
        row(
          l10n.registrationCloses,
          '${formatDay(locale, closes)} ${formatTime(locale, '${closes.hour.toString().padLeft(2, '0')}:${closes.minute.toString().padLeft(2, '0')}:00')}',
        ),
        row(l10n.startsOn, formatLongDay(locale, parseApiDay(item.startDate))),
        row(l10n.endsOn, formatLongDay(locale, parseApiDay(item.endDate))),
        row(
          l10n.timeLabel,
          l10n.timeRange(formatTime(locale, tournament.dailyStartTime), formatTime(locale, tournament.dailyEndTime)),
        ),
        row(l10n.matchLength, l10n.minutesLabel(tournament.matchMinutes)),
        if (tournament.courts.isNotEmpty) row(l10n.tournamentCourts, tournament.courts.join('، ')),
        section(l10n.description, tournament.description),
        section(l10n.rules, tournament.rules),
        section(l10n.prizes, tournament.prizes),
      ],
    );
  }
}

class _TeamsTab extends ConsumerWidget {
  const _TeamsTab({required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final teams = ref.watch(tournamentTeamsProvider(tournamentId));

    return teams.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(tournamentTeamsProvider(tournamentId)),
      ),
      data: (teams) => teams.isEmpty
          ? EmptyView(message: l10n.noTeams, icon: Icons.groups_outlined)
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.s),
              children: [
                for (final team in teams)
                  ListTile(
                    leading: UserAvatar(name: team.name, url: team.logoUrl),
                    title: Text(team.name, style: AppTextStyles.body1Semibold),
                    subtitle: Text(team.captain.fullName),
                    trailing: team.groupNumber == null
                        ? null
                        : Text(l10n.groupNumber(team.groupNumber!), style: AppTextStyles.caption),
                    onTap: () => context.push('/team/${team.id}'),
                  ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../tournaments/application/tournament_controllers.dart';
import '../../tournaments/data/tournament_models.dart';
import '../../tournaments/presentation/tournament_labels.dart';
import '../application/owner_tournament_controllers.dart';
import '../data/owner_tournament_repository.dart';

enum _Menu { poster, cancel }

class OwnerTournamentScreen extends ConsumerStatefulWidget {
  const OwnerTournamentScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  ConsumerState<OwnerTournamentScreen> createState() => _OwnerTournamentScreenState();
}

class _OwnerTournamentScreenState extends ConsumerState<OwnerTournamentScreen> {
  bool _busy = false;

  String get id => widget.tournamentId;

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ownerTournamentProvider(id));
      ref.invalidate(ownerTournamentTeamsProvider(id));
      ref.invalidate(tournamentMatchesProvider(id));
      if (mounted) showSnack(context, done ?? context.l10n.tournamentActionDone);
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askReason(String title) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.cancelReasonRequired),
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
    final reason = controller.text.trim();
    controller.dispose();
    return confirmed == true && reason.isNotEmpty ? reason : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repository = ref.read(ownerTournamentRepositoryProvider);
    final tournament = ref.watch(ownerTournamentProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.valueOrNull?.item.name ?? l10n.tournamentDetails),
        actions: [
          PopupMenuButton<_Menu>(
            onSelected: (menu) async {
              if (menu == _Menu.poster) {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 2000,
                );
                if (picked != null) await _run(() => repository.setPoster(id, picked.path));
              } else {
                final reason = await _askReason(l10n.cancelTournament);
                if (reason != null) await _run(() => repository.cancel(id, reason));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: _Menu.poster, child: Text(l10n.pickPoster)),
              PopupMenuItem(value: _Menu.cancel, child: Text(l10n.cancelTournament)),
            ],
          ),
        ],
      ),
      body: tournament.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(ownerTournamentProvider(id)),
        ),
        data: (tournament) => DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            tournament.status.label(l10n),
                            style: AppTextStyles.caption.copyWith(color: AppColors.white),
                          ),
                          backgroundColor: tournament.status.color,
                          side: BorderSide.none,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Chip(label: Text(l10n.teamsCount(tournament.item.approvedTeams, tournament.item.maxTeams))),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/tournament/$id'),
                          child: Text(l10n.tournamentDetails),
                        ),
                      ],
                    ),
                    if (tournament.status == TournamentStatus.draft)
                      AppButton(
                        label: l10n.publishTournament,
                        isLoading: _busy,
                        onPressed: () => _run(() => repository.publish(id)),
                      ),
                    if (tournament.status == TournamentStatus.registrationOpen)
                      AppButton(
                        label: l10n.closeRegistration,
                        isLoading: _busy,
                        onPressed: () => _run(() => repository.closeRegistration(id)),
                      ),
                    if (tournament.status == TournamentStatus.registrationClosed)
                      AppButton(
                        label: l10n.drawTournament,
                        isLoading: _busy,
                        onPressed: () => _run(() => repository.draw(id)),
                      ),
                  ],
                ),
              ),
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.black600,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: l10n.tabTeams),
                  Tab(text: l10n.tabMatches),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TeamsTab(tournamentId: id),
                    _MatchesTab(tournamentId: id, courts: tournament.courtRefs),
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

class _TeamsTab extends ConsumerWidget {
  const _TeamsTab({required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final teams = ref.watch(ownerTournamentTeamsProvider(tournamentId));
    final repository = ref.read(ownerTournamentRepositoryProvider);

    Future<void> answer(Future<void> Function() action) async {
      try {
        await action();
        ref.invalidate(ownerTournamentTeamsProvider(tournamentId));
        ref.invalidate(ownerTournamentProvider(tournamentId));
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    Future<void> reject(Team team) async {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.rejectTeamTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.cancelReasonRequired),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.rejectTeam, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      final reason = controller.text.trim();
      controller.dispose();
      if (confirmed == true && reason.isNotEmpty) await answer(() => repository.reject(tournamentId, team.id, reason));
    }

    return teams.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(ownerTournamentTeamsProvider(tournamentId)),
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
                    subtitle: Text('${team.captain.fullName} · ${team.status.label(l10n)}'),
                    trailing: team.status == TeamStatus.pendingApproval
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.error),
                                tooltip: l10n.rejectTeam,
                                onPressed: () => reject(team),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.primary),
                                tooltip: l10n.approveTeam,
                                onPressed: () => answer(() => repository.approve(tournamentId, team.id)),
                              ),
                            ],
                          )
                        : null,
                    onTap: () => context.push('/team/${team.id}'),
                  ),
              ],
            ),
    );
  }
}

class _MatchesTab extends ConsumerWidget {
  const _MatchesTab({required this.tournamentId, required this.courts});

  final String tournamentId;
  final List<({String id, String name})> courts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final matches = ref.watch(tournamentMatchesProvider(tournamentId));

    Future<void> enterResult(TournamentMatch match) async {
      final home = TextEditingController(text: '${match.homeScore ?? 0}');
      final away = TextEditingController(text: '${match.awayScore ?? 0}');
      String? winner = match.winnerTeamId;

      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.enterResult),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${match.home?.name ?? ''} - ${match.away?.name ?? ''}', style: AppTextStyles.body2),
                TextField(
                  controller: home,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.homeScore),
                ),
                TextField(
                  controller: away,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.awayScore),
                ),
                if (match.stage == TournamentStage.knockout)
                  DropdownButtonFormField<String?>(
                    initialValue: winner,
                    hint: Text(l10n.winnerOnDraw),
                    items: [
                      if (match.home != null) DropdownMenuItem(value: match.home!.id, child: Text(match.home!.name)),
                      if (match.away != null) DropdownMenuItem(value: match.away!.id, child: Text(match.away!.name)),
                    ],
                    onChanged: (value) => setState(() => winner = value),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
            ],
          ),
        ),
      );
      final homeScore = int.tryParse(home.text.trim());
      final awayScore = int.tryParse(away.text.trim());
      home.dispose();
      away.dispose();
      if (saved != true || homeScore == null || awayScore == null) return;

      try {
        await ref
            .read(ownerTournamentRepositoryProvider)
            .setResult(
              match.id,
              home: homeScore,
              away: awayScore,
              winnerTeamId: homeScore == awayScore ? winner : null,
            );
        ref.invalidate(tournamentMatchesProvider(tournamentId));
        ref.invalidate(tournamentStandingsProvider(tournamentId));
        if (context.mounted) showSnack(context, l10n.resultSaved);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    Future<void> reschedule(TournamentMatch match) async {
      var courtId = courts.isEmpty ? null : courts.first.id;
      DateTime? day = match.day == null ? null : parseApiDay(match.day!);
      TimeOfDay? time;
      if (match.startTime != null) {
        final parts = match.startTime!.split(':');
        time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      String hms(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.rescheduleMatch),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: courtId,
                  decoration: InputDecoration(labelText: l10n.pickCourt),
                  items: [for (final court in courts) DropdownMenuItem(value: court.id, child: Text(court.name))],
                  onChanged: (value) => setState(() => courtId = value),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(day == null ? l10n.pickDate : formatLongDay(locale, day!)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final first = today();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: day ?? first,
                      firstDate: first,
                      lastDate: first.add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => day = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(time == null ? l10n.pickTime : formatTime(locale, hms(time!))),
                  trailing: const Icon(Icons.schedule_outlined),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time ?? const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (picked == null) return;
                    final snapped = picked.minute < 15
                        ? 0
                        : picked.minute < 45
                        ? 30
                        : 60;
                    setState(
                      () => time = snapped == 60
                          ? TimeOfDay(hour: (picked.hour + 1) % 24, minute: 0)
                          : TimeOfDay(hour: picked.hour, minute: snapped),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
            ],
          ),
        ),
      );
      if (saved != true || courtId == null || day == null || time == null) return;

      try {
        await ref
            .read(ownerTournamentRepositoryProvider)
            .reschedule(match.id, courtId: courtId!, day: day!, startTime: hms(time!));
        ref.invalidate(tournamentMatchesProvider(tournamentId));
        if (context.mounted) showSnack(context, l10n.rescheduled);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    return matches.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(tournamentMatchesProvider(tournamentId)),
      ),
      data: (matches) => matches.isEmpty
          ? EmptyView(message: l10n.noMatchesYet, icon: Icons.sports_score_outlined)
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.s),
              children: [
                for (final match in matches.where((m) => !m.isBye))
                  ListTile(
                    title: Text(
                      '${match.home?.name ?? l10n.tbd}  ${match.status == TournamentMatchStatus.completed ? '${match.homeScore} - ${match.awayScore}' : 'vs'}  ${match.away?.name ?? l10n.tbd}',
                      style: AppTextStyles.body1Semibold,
                    ),
                    subtitle: Text(
                      match.day == null
                          ? l10n.roundLabel(match.round)
                          : '${formatDay(locale, parseApiDay(match.day!))} ${match.startTime == null ? '' : formatTime(locale, match.startTime!)} · ${match.courtName ?? ''}',
                    ),
                    trailing:
                        match.status == TournamentMatchStatus.completed ||
                            match.status == TournamentMatchStatus.cancelled
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.event_repeat_outlined),
                            tooltip: l10n.rescheduleMatch,
                            onPressed: () => reschedule(match),
                          ),
                    onTap: match.home != null && match.away != null && match.status != TournamentMatchStatus.cancelled
                        ? () => enterResult(match)
                        : null,
                  ),
              ],
            ),
    );
  }
}

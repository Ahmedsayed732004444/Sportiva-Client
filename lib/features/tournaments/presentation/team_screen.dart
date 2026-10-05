import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_controller.dart';
import '../../payments/presentation/pay_flow.dart';
import '../../social/presentation/person_picker_sheet.dart';
import '../application/tournament_controllers.dart';
import '../data/tournament_models.dart';
import '../data/tournament_repository.dart';
import 'tournament_labels.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamProvider(teamId));

    return Scaffold(
      appBar: AppBar(title: Text(team.valueOrNull?.name ?? context.l10n.myTeam)),
      body: team.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(teamProvider(teamId)),
        ),
        data: (team) => _Body(team: team),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.team});

  final Team team;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;

  Team get team => widget.team;

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(teamProvider(team.id));
      ref.invalidate(myTeamsProvider);
      ref.invalidate(tournamentProvider(team.tournamentId));
      if (mounted && done != null) showSnack(context, done);
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite() async {
    final picked = await showPersonPicker(context, askSubstitute: true);
    if (picked == null || !mounted) return;
    await _run(
      () => ref
          .read(tournamentRepositoryProvider)
          .invite(team.id, picked.person.userId, isSubstitute: picked.isSubstitute),
      done: context.l10n.inviteSent,
    );
  }

  Future<void> _pay() async {
    if (_busy) return;
    setState(() => _busy = true);
    await startPayment(context, ref, (method) => ref.read(tournamentRepositoryProvider).pay(team.id, method));
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _withdraw() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.withdrawTeam),
        content: Text(l10n.withdrawBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.withdrawTeam, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() => ref.read(tournamentRepositoryProvider).withdraw(team.id), done: l10n.withdrawn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final me = ref.watch(authControllerProvider).valueOrNull?.userId;
    final isCaptain = team.captain.userId == me;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            UserAvatar(name: team.name, url: team.logoUrl, radius: 32),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name, style: AppTextStyles.header),
                  InkWell(
                    onTap: () => context.push('/tournament/${team.tournamentId}'),
                    child: Text(team.tournamentName, style: AppTextStyles.body2.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Chip(
          label: Text(team.status.label(l10n), style: AppTextStyles.caption.copyWith(color: AppColors.white)),
          backgroundColor: team.status.color,
          side: BorderSide.none,
        ),
        if (team.status == TeamStatus.rejected && team.rejectionReason != null)
          Text(
            l10n.rejectionReason(team.rejectionReason!),
            style: AppTextStyles.body2.copyWith(color: AppColors.error),
          ),
        const SizedBox(height: AppSpacing.m),
        Text(l10n.players, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        for (final member in team.members.where((m) => m.status != MemberStatus.removed))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UserAvatar(name: member.player.fullName, url: member.player.avatarUrl),
            title: Text(member.player.fullName, style: AppTextStyles.body1),
            subtitle: Text(
              [
                if (member.isCaptain) l10n.captain,
                if (member.isSubstitute) l10n.substitute,
                member.status.label(l10n),
              ].join(' · '),
              style: AppTextStyles.caption,
            ),
            onTap: () => context.push('/user/${member.player.userId}'),
            trailing: isCaptain && !member.isCaptain && team.status.isActive
                ? IconButton(
                    icon: const Icon(Icons.person_remove_outlined, color: AppColors.error),
                    tooltip: l10n.removeMember,
                    onPressed: () =>
                        _run(() => ref.read(tournamentRepositoryProvider).removeMember(team.id, member.player.userId)),
                  )
                : null,
          ),
        if (isCaptain && team.status.isActive) ...[
          const SizedBox(height: AppSpacing.m),
          if (team.status == TeamStatus.forming || team.status == TeamStatus.pendingPayment)
            AppButton(label: l10n.invitePlayer, style: AppButtonStyle.outlined, isLoading: _busy, onPressed: _invite),
          if (team.status == TeamStatus.pendingPayment || team.status == TeamStatus.forming) ...[
            const SizedBox(height: AppSpacing.s),
            AppButton(label: l10n.payNow, isLoading: _busy, onPressed: _pay),
          ],
          const SizedBox(height: AppSpacing.s),
          AppButton(label: l10n.withdrawTeam, style: AppButtonStyle.outlined, isLoading: _busy, onPressed: _withdraw),
        ],
      ],
    );
  }
}

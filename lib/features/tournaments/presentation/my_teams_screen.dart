import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/tournament_controllers.dart';
import '../data/tournament_repository.dart';
import 'tournament_labels.dart';

class MyTeamsScreen extends ConsumerWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final invitations = ref.watch(invitationsProvider).valueOrNull?.length ?? 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.teamsAndInvitations),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.black600,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: l10n.myTeams),
              Tab(
                child: Badge(
                  isLabelVisible: invitations > 0,
                  label: Text('$invitations'),
                  child: Text(l10n.invitations),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_Teams(), _Invitations()]),
      ),
    );
  }
}

class _Teams extends ConsumerWidget {
  const _Teams();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final teams = ref.watch(myTeamsProvider);

    return teams.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(myTeamsProvider),
      ),
      data: (teams) => teams.isEmpty
          ? EmptyView(message: l10n.noMyTeams, icon: Icons.groups_outlined)
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(myTeamsProvider),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s),
                children: [
                  for (final team in teams)
                    ListTile(
                      leading: UserAvatar(name: team.name, url: team.logoUrl),
                      title: Text(team.name, style: AppTextStyles.body1Semibold),
                      subtitle: Text(team.tournamentName),
                      trailing: Text(
                        team.status.label(l10n),
                        style: AppTextStyles.caption.copyWith(color: team.status.color, fontWeight: FontWeight.w700),
                      ),
                      onTap: () => context.push('/team/${team.id}'),
                    ),
                ],
              ),
            ),
    );
  }
}

class _Invitations extends ConsumerWidget {
  const _Invitations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final invitations = ref.watch(invitationsProvider);

    Future<void> answer(Future<void> Function() action, String done) async {
      try {
        await action();
        ref.invalidate(invitationsProvider);
        ref.invalidate(myTeamsProvider);
        if (context.mounted) showSnack(context, done);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    return invitations.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(invitationsProvider),
      ),
      data: (items) => items.isEmpty
          ? EmptyView(message: l10n.noInvitations, icon: Icons.mail_outline)
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.s),
              children: [
                for (final invitation in items)
                  Card(
                    elevation: 0,
                    color: AppColors.gray200,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invitation.teamName, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                          Text(invitation.tournamentName, style: AppTextStyles.body2),
                          Text(
                            '${l10n.invitedBy(invitation.captain.fullName)} · ${formatDay(locale, parseApiDay(invitation.startDate))}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                          ),
                          if (invitation.isSubstitute)
                            Text(l10n.substitute, style: AppTextStyles.caption.copyWith(color: AppColors.primaryMid)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => answer(
                                  () => ref.read(tournamentRepositoryProvider).declineInvitation(invitation.teamId),
                                  l10n.invitationDeclined,
                                ),
                                child: Text(l10n.decline, style: const TextStyle(color: AppColors.error)),
                              ),
                              FilledButton(
                                onPressed: () => answer(
                                  () => ref.read(tournamentRepositoryProvider).acceptInvitation(invitation.teamId),
                                  l10n.invitationAccepted,
                                ),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                child: Text(l10n.accept),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

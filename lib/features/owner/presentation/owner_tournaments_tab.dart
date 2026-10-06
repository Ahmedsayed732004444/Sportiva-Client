import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../tournaments/data/tournament_models.dart';
import '../../tournaments/presentation/widgets/tournament_card.dart';
import '../application/owner_tournament_controllers.dart';

class OwnerTournamentsTab extends StatelessWidget {
  const OwnerTournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/owner/tournaments/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onBrand,
        icon: const Icon(Icons.add),
        label: Text(l10n.createTournament),
      ),
      body: PagedListView<TournamentListItem>(
        state: ownerTournamentsProvider,
        actions: ownerTournamentsProvider.notifier,
        emptyMessage: l10n.noManagedTournaments,
        emptyIcon: Icons.emoji_events_outlined,
        padding: const EdgeInsets.all(AppSpacing.s),
        separator: const SizedBox(height: AppSpacing.s),
        itemBuilder: (context, tournament) =>
            TournamentCard(tournament: tournament, route: '/owner/tournament/${tournament.id}'),
      ),
    );
  }
}

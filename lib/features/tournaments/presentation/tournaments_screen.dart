import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../catalog/data/sport_type.dart';
import '../application/tournament_controllers.dart';
import '../data/tournament_models.dart';
import 'widgets/tournament_card.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sport = ref.watch(tournamentSportFilterProvider);
    final openOnly = ref.watch(tournamentOpenOnlyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tournaments)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, AppSpacing.s, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.openTournaments),
                    selected: openOnly,
                    onSelected: (value) => ref.read(tournamentOpenOnlyProvider.notifier).state = value,
                  ),
                  ChoiceChips<SportType?>(
                    options: [null, ...SportType.homeSports],
                    selected: sport,
                    labelOf: (s) => s?.label(l10n) ?? l10n.allSports,
                    onSelected: (s) => ref.read(tournamentSportFilterProvider.notifier).state = s,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PagedListView<TournamentListItem>(
              state: tournamentsProvider,
              actions: tournamentsProvider.notifier,
              emptyMessage: l10n.noTournaments,
              emptyIcon: Icons.emoji_events_outlined,
              padding: const EdgeInsets.all(AppSpacing.s),
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, tournament) => TournamentCard(tournament: tournament),
            ),
          ),
        ],
      ),
    );
  }
}

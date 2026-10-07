import '../../../core/widgets/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../catalog/data/sport_type.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../application/matches_controller.dart';
import '../data/match_models.dart';
import 'widgets/match_card.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sport = ref.watch(matchSportFilterProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navMatches),
          actions: const [NotificationBell()],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.black600,
            indicatorColor: AppColors.primary,
            labelStyle: AppTextStyles.body1Semibold,
            unselectedLabelStyle: AppTextStyles.body1,
            tabs: [
              Tab(text: l10n.openMatches),
              Tab(text: l10n.myMatches),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => context.push('/matches/create'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBrand,
          icon: const Icon(Icons.add),
          label: Text(l10n.createMatch),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, AppSpacing.s, 0),
                  child: SearchBox(
                    hint: l10n.searchMatches,
                    initial: ref.read(matchSearchProvider),
                    onChanged: (text) => ref.read(matchSearchProvider.notifier).state = text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, AppSpacing.s, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ChoiceChips<SportType?>(
                      options: [null, ...SportType.homeSports],
                      selected: sport,
                      labelOf: (s) => s?.label(l10n) ?? l10n.allSports,
                      onSelected: (s) => ref.read(matchSportFilterProvider.notifier).state = s,
                    ),
                  ),
                ),
                Expanded(
                  child: PagedListView<FriendlyMatch>(
                    state: openMatchesProvider,
                    actions: openMatchesProvider.notifier,
                    emptyMessage: l10n.noOpenMatches,
                    emptyIcon: Icons.sports_soccer_outlined,
                    padding: const EdgeInsets.all(AppSpacing.s),
                    separator: const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, match) => MatchCard(match: match),
                  ),
                ),
              ],
            ),
            PagedListView<FriendlyMatch>(
              state: myMatchesProvider,
              actions: myMatchesProvider.notifier,
              emptyMessage: l10n.noMyMatches,
              emptyIcon: Icons.sports_soccer_outlined,
              padding: const EdgeInsets.all(AppSpacing.s),
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, match) => MatchCard(match: match),
            ),
          ],
        ),
      ),
    );
  }
}

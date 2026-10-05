import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/data/sport_type.dart';
import '../../home/presentation/widgets/court_card.dart';

final _pickerSportProvider = StateProvider.autoDispose<SportType>((ref) => SportType.football);

class _CourtPickerController extends PagedController<CourtListItem> {
  @override
  PagedState<CourtListItem> build() {
    // Another sport rebuilds the list from the first page.
    ref.watch(_pickerSportProvider);
    return super.build();
  }

  @override
  Future<PagedResult<CourtListItem>> fetch(int page) async {
    final position = (await ref.read(locationProvider.future)).position;
    return ref.read(catalogRepositoryProvider).courts(sport: ref.read(_pickerSportProvider), at: position, page: page);
  }
}

final _courtsProvider = AutoDisposeNotifierProvider<_CourtPickerController, PagedState<CourtListItem>>(
  _CourtPickerController.new,
);

// Step one of a match on a club's court: pick the court (nearest first), then its day and time.
class CourtPickerScreen extends ConsumerWidget {
  const CourtPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sport = ref.watch(_pickerSportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickCourtTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, AppSpacing.s, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ChoiceChips<SportType>(
                options: SportType.values.where((s) => s != SportType.other).toList(),
                selected: sport,
                labelOf: (s) => s.label(l10n),
                onSelected: (s) => ref.read(_pickerSportProvider.notifier).state = s,
              ),
            ),
          ),
          Expanded(
            child: PagedListView<CourtListItem>(
              state: _courtsProvider,
              actions: _courtsProvider.notifier,
              emptyMessage: l10n.noCourtsForSport,
              emptyIcon: sport.icon,
              padding: const EdgeInsets.all(AppSpacing.s),
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, court) => CourtCard(
                court: court,
                width: double.infinity,
                onTap: () => context.pushReplacement('/court/${court.id}?match=1'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

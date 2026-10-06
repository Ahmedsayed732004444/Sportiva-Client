import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../home/presentation/widgets/court_card.dart';
import '../application/courts_list_controller.dart';
import '../data/catalog_models.dart';
import '../data/sport_type.dart';

// The courts of a sport, nearest first. With [matchMode] picking one is the first step of a match on a club's court.
class CourtsScreen extends ConsumerStatefulWidget {
  const CourtsScreen({super.key, required this.sport, this.matchMode = false});

  final SportType sport;
  final bool matchMode;

  @override
  ConsumerState<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends ConsumerState<CourtsScreen> {
  late SportType _sport = widget.sport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = courtsListProvider(_sport);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matchMode ? l10n.pickCourtTitle : l10n.courtsOfSport(_sport.label(l10n))),
        actions: [
          if (!widget.matchMode)
            IconButton(
              tooltip: l10n.searchFilters,
              icon: const Icon(Icons.tune),
              onPressed: () => context.push('/find?sport=${_sport.apiName}'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, AppSpacing.s, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ChoiceChips<SportType>(
                options: SportType.values.where((s) => s != SportType.other).toList(),
                selected: _sport,
                labelOf: (s) => s.label(l10n),
                onSelected: (s) => setState(() => _sport = s),
              ),
            ),
          ),
          Expanded(
            child: PagedListView<CourtListItem>(
              state: provider,
              actions: provider.notifier,
              emptyMessage: l10n.noCourtsForSport,
              emptyIcon: _sport.icon,
              padding: const EdgeInsets.all(AppSpacing.s),
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, court) => CourtCard(
                court: court,
                width: double.infinity,
                onTap: () => widget.matchMode
                    ? context.pushReplacement('/court/${court.id}?match=1')
                    : context.push('/court/${court.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

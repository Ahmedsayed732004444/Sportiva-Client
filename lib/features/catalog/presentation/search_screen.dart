import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../home/presentation/widgets/club_card.dart';
import '../../home/presentation/widgets/court_card.dart';
import '../application/search_providers.dart';
import '../data/search_filters.dart';
import '../data/sport_type.dart';
import 'widgets/filters_sheet.dart';

// Find a club or a court: words, then the filters in a sheet (sport, place, price, rating, distance, sort).
class CatalogSearchScreen extends ConsumerStatefulWidget {
  const CatalogSearchScreen({super.key, this.sport, this.clubsFirst = false});

  final SportType? sport;
  final bool clubsFirst;

  @override
  ConsumerState<CatalogSearchScreen> createState() => _CatalogSearchScreenState();
}

class _CatalogSearchScreenState extends ConsumerState<CatalogSearchScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this, initialIndex: widget.clubsFirst ? 1 : 0);
  final _field = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.sport != null) {
      Future.microtask(() => ref.read(searchFiltersProvider.notifier).set(SearchFilters(sport: widget.sport)));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabs.dispose();
    _field.dispose();
    super.dispose();
  }

  void _typed(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => ref.read(searchFiltersProvider.notifier).setQuery(text));
  }

  Future<void> _openFilters() async {
    final next = await showFiltersSheet(context, ref.read(searchFiltersProvider));
    if (next != null) ref.read(searchFiltersProvider.notifier).set(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = ref.watch(searchFiltersProvider);
    final active = filters.activeCount;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _field,
          autofocus: false,
          textInputAction: TextInputAction.search,
          style: AppTextStyles.body1,
          onChanged: _typed,
          onSubmitted: (text) => ref.read(searchFiltersProvider.notifier).setQuery(text),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _field.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _field.clear();
                      ref.read(searchFiltersProvider.notifier).setQuery('');
                      setState(() {});
                    },
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.s),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.searchFilters,
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: active > 0,
              label: Text('$active'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.black600,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: l10n.courts),
            Tab(text: l10n.searchClubsTab),
          ],
        ),
      ),
      body: Column(
        children: [
          if (active > 0 || filters.sort != SearchSort.nearest) _ActiveFilters(filters: filters),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                PagedListView<dynamic>(
                  key: ValueKey(('courts', filters.hashCode)),
                  state: courtSearchProvider,
                  actions: courtSearchProvider.notifier,
                  emptyMessage: l10n.searchNoResults,
                  emptyIcon: Icons.search_off,
                  padding: const EdgeInsets.all(AppSpacing.s),
                  separator: const SizedBox(height: AppSpacing.s),
                  itemBuilder: (context, court) =>
                      CourtCard(court: court, width: double.infinity, onTap: () => context.push('/court/${court.id}')),
                ),
                PagedListView<dynamic>(
                  key: ValueKey(('clubs', filters.hashCode)),
                  state: clubSearchProvider,
                  actions: clubSearchProvider.notifier,
                  emptyMessage: l10n.searchNoResults,
                  emptyIcon: Icons.search_off,
                  padding: const EdgeInsets.all(AppSpacing.s),
                  separator: const SizedBox(height: AppSpacing.s),
                  itemBuilder: (context, club) => ClubCard(club: club, onTap: () => context.push('/club/${club.id}')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// What is on, as removable chips under the bar.
class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters({required this.filters});

  final SearchFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(searchFiltersProvider.notifier);

    Widget chip(String label, SearchFilters Function() without) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: InputChip(
        label: Text(label, style: AppTextStyles.caption),
        visualDensity: VisualDensity.compact,
        onDeleted: () => controller.set(without()),
      ),
    );

    final price = filters.minPrice == null && filters.maxPrice == null
        ? null
        : filters.minPrice == null
        ? l10n.filterPriceUpTo('${filters.maxPrice}')
        : filters.maxPrice == null
        ? l10n.filterPriceFrom('${filters.minPrice}')
        : l10n.filterPriceBetween('${filters.minPrice}', '${filters.maxPrice}');

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        children: [
          if (filters.sport != null) chip(filters.sport!.label(l10n), () => filters.copyWith(sport: null)),
          if (filters.governorateId != null) chip(l10n.filterGovernorate, () => filters.copyWith(governorateId: null)),
          if (filters.city?.trim().isNotEmpty ?? false) chip(filters.city!, () => filters.copyWith(city: null)),
          if (price != null) chip(price, () => filters.copyWith(minPrice: null, maxPrice: null)),
          if (filters.minRating != null)
            chip(l10n.filterRatingFrom('${filters.minRating}'), () => filters.copyWith(minRating: null)),
          if (filters.maxKm != null)
            chip(l10n.kmShort('${filters.maxKm!.round()}'), () => filters.copyWith(maxKm: null)),
          if (filters.sort != SearchSort.nearest)
            chip(switch (filters.sort) {
              SearchSort.priceLow => l10n.sortPriceLow,
              SearchSort.priceHigh => l10n.sortPriceHigh,
              _ => l10n.sortRating,
            }, () => filters.copyWith(sort: SearchSort.nearest)),
        ],
      ),
    );
  }
}

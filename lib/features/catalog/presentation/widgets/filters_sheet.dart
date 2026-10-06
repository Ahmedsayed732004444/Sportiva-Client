import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/location/location_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../matches/application/matches_controller.dart';
import '../../data/search_filters.dart';
import '../../data/sport_type.dart';

// The filters as a bottom sheet. Returns the new filters when the player taps "Show results", or null when they leave.
Future<SearchFilters?> showFiltersSheet(BuildContext context, SearchFilters current) =>
    showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FiltersSheet(initial: current),
    );

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet({required this.initial});

  final SearchFilters initial;

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  static const _priceMax = 1000.0;
  static const _distances = [2.0, 5.0, 10.0, 25.0, 50.0];
  static const _ratings = [3.0, 4.0, 4.5];

  late SearchFilters _f = widget.initial;
  late final _city = TextEditingController(text: widget.initial.city);
  late RangeValues _price = RangeValues(
    (widget.initial.minPrice ?? 0).toDouble(),
    (widget.initial.maxPrice ?? _priceMax).toDouble(),
  );

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  SearchFilters _result() {
    final city = _city.text.trim();
    return _f.copyWith(
      city: city.isEmpty ? null : city,
      minPrice: _price.start <= 0 ? null : _price.start.round(),
      maxPrice: _price.end >= _priceMax ? null : _price.end.round(),
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.xs),
    child: Text(text, style: AppTextStyles.body1Semibold),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final governorates = ref.watch(governoratesProvider).valueOrNull ?? const [];
    final hasLocation = ref.watch(locationProvider).valueOrNull?.position != null;

    final priceLabel = _price.start <= 0 && _price.end >= _priceMax
        ? l10n.filterPriceAny
        : _price.start <= 0
        ? l10n.filterPriceUpTo(_price.end.round().toString())
        : _price.end >= _priceMax
        ? l10n.filterPriceFrom(_price.start.round().toString())
        : l10n.filterPriceBetween(_price.start.round().toString(), _price.end.round().toString());

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  children: [
                    Text(l10n.searchFilters, style: AppTextStyles.header),
                    _title(l10n.filterSport),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.allSports),
                          selected: _f.sport == null,
                          onSelected: (_) => setState(() => _f = _f.copyWith(sport: null)),
                        ),
                        for (final sport in SportType.values.where((s) => s != SportType.other))
                          ChoiceChip(
                            avatar: Icon(sport.icon, size: 18),
                            label: Text(sport.label(l10n)),
                            selected: _f.sport == sport,
                            onSelected: (_) => setState(() => _f = _f.copyWith(sport: sport)),
                          ),
                      ],
                    ),
                    _title(l10n.filterGovernorate),
                    DropdownButtonFormField<int?>(
                      initialValue: _f.governorateId,
                      isExpanded: true,
                      decoration: const InputDecoration(),
                      style: AppTextStyles.body1,
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text(l10n.filterAnyGovernorate)),
                        for (final g in governorates) DropdownMenuItem<int?>(value: g.id, child: Text(g.name(locale))),
                      ],
                      onChanged: (value) => setState(() => _f = _f.copyWith(governorateId: value)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _city,
                      style: AppTextStyles.body1,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: l10n.filterCityHint,
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                    ),
                    _title('${l10n.filterPrice}: $priceLabel'),
                    RangeSlider(
                      values: _price,
                      max: _priceMax,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      labels: RangeLabels(
                        _price.start.round().toString(),
                        _price.end >= _priceMax ? '${_priceMax.round()}+' : _price.end.round().toString(),
                      ),
                      onChanged: (values) => setState(() => _price = values),
                    ),
                    _title(l10n.filterRating),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.filterRatingAny),
                          selected: _f.minRating == null,
                          onSelected: (_) => setState(() => _f = _f.copyWith(minRating: null)),
                        ),
                        for (final rating in _ratings)
                          ChoiceChip(
                            avatar: Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                            label: Text(l10n.filterRatingFrom(rating.toString())),
                            selected: _f.minRating == rating,
                            onSelected: (_) => setState(() => _f = _f.copyWith(minRating: rating)),
                          ),
                      ],
                    ),
                    _title(l10n.filterDistance),
                    if (!hasLocation)
                      Text(
                        l10n.filterDistanceNeedsLocation,
                        style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.filterDistanceAny),
                            selected: _f.maxKm == null,
                            onSelected: (_) => setState(() => _f = _f.copyWith(maxKm: null)),
                          ),
                          for (final km in _distances)
                            ChoiceChip(
                              avatar: const Icon(Icons.near_me_outlined, size: 16),
                              label: Text(l10n.kmShort(km.round().toString())),
                              selected: _f.maxKm == km,
                              onSelected: (_) => setState(() => _f = _f.copyWith(maxKm: km)),
                            ),
                        ],
                      ),
                    _title(l10n.filterSort),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (sort, label) in [
                          (SearchSort.nearest, l10n.sortNearest),
                          (SearchSort.priceLow, l10n.sortPriceLow),
                          (SearchSort.priceHigh, l10n.sortPriceHigh),
                          (SearchSort.rating, l10n.sortRating),
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: _f.sort == sort,
                            onSelected: (_) => setState(() => _f = _f.copyWith(sort: sort)),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: l10n.filtersReset,
                        style: AppButtonStyle.outlined,
                        onPressed: () => setState(() {
                          _f = SearchFilters(query: widget.initial.query);
                          _city.clear();
                          _price = const RangeValues(0, _priceMax);
                        }),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      flex: 2,
                      child: AppButton(label: l10n.filtersApply, onPressed: () => Navigator.of(context).pop(_result())),
                    ),
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

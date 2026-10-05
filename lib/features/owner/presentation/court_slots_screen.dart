import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../data/owner_court_models.dart';
import '../data/owner_court_repository.dart';

// A court's day in 30-minute units. Tapping a free one closes it for booking; tapping a closed one opens it.
class CourtSlotsScreen extends ConsumerStatefulWidget {
  const CourtSlotsScreen({super.key, required this.courtId});

  final String courtId;

  @override
  ConsumerState<CourtSlotsScreen> createState() => _CourtSlotsScreenState();
}

class _CourtSlotsScreenState extends ConsumerState<CourtSlotsScreen> {
  late DateTime _day = today();
  List<ManagedSlot>? _slots;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _slots = null;
      _error = null;
    });
    try {
      final slots = await ref.read(ownerCourtRepositoryProvider).slots(widget.courtId, _day);
      if (mounted) setState(() => _slots = slots);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _toggle(ManagedSlot slot) async {
    try {
      await ref.read(ownerCourtRepositoryProvider).setSlotsClosed(widget.courtId, [slot.id], closed: !slot.isClosed);
      await _load();
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final days = [for (var i = 0; i < 14; i++) today().add(Duration(days: i))];
    final slots = _slots;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.slotsAndClosing)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(l10n.slotsHint, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) => ChoiceChip(
                label: Text(formatDay(locale, days[index])),
                selected: days[index] == _day,
                onSelected: (_) {
                  setState(() => _day = days[index]);
                  _load();
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (_error != null)
            ErrorView(error: _error!, onRetry: _load)
          else if (slots == null)
            const SizedBox(height: 200, child: LoadingView())
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in slots)
                  FilterChip(
                    label: Text(
                      slot.isBooked
                          ? '${formatTime(locale, slot.startTime)} · ${l10n.slotBooked}'
                          : formatTime(locale, slot.startTime),
                    ),
                    selected: slot.isClosed,
                    selectedColor: AppColors.error.withValues(alpha: 0.2),
                    onSelected: slot.isBooked ? null : (_) => _toggle(slot),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

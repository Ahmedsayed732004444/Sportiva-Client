import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../../l10n/app_localizations.dart';
import '../data/owner_court_models.dart';
import '../data/owner_court_repository.dart';

String weekdayLabel(AppLocalizations l10n, int? day) => switch (day) {
  0 => l10n.weekdaySun,
  1 => l10n.weekdayMon,
  2 => l10n.weekdayTue,
  3 => l10n.weekdayWed,
  4 => l10n.weekdayThu,
  5 => l10n.weekdayFri,
  6 => l10n.weekdaySat,
  _ => l10n.anyDay,
};

String _hms(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

class PriceRulesScreen extends ConsumerStatefulWidget {
  const PriceRulesScreen({super.key, required this.courtId});

  final String courtId;

  @override
  ConsumerState<PriceRulesScreen> createState() => _PriceRulesScreenState();
}

class _PriceRulesScreenState extends ConsumerState<PriceRulesScreen> with SubmitMixin {
  List<PriceRule>? _rules;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final court = await ref.read(ownerCourtRepositoryProvider).get(widget.courtId);
      if (mounted) setState(() => _rules = court.priceRules);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  // The API wants the hour or the half hour: a picked time snaps to the nearest one.
  Future<String?> _pickTime(String initial) async {
    final parts = initial.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked == null) return null;
    final snapped = picked.minute < 15
        ? 0
        : picked.minute < 45
        ? 30
        : 60;
    return _hms(
      snapped == 60
          ? TimeOfDay(hour: (picked.hour + 1) % 24, minute: 0)
          : TimeOfDay(hour: picked.hour, minute: snapped),
    );
  }

  Future<void> _edit({PriceRule? rule, int? index}) async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    var day = rule?.dayOfWeek;
    var start = rule?.startTime ?? '18:00:00';
    var end = rule?.endTime ?? '23:00:00';
    final price = TextEditingController(text: rule == null ? '' : formatPounds(rule.pricePiasters));
    final half = TextEditingController(
      text: rule?.halfCourtPiasters == null ? '' : formatPounds(rule!.halfCourtPiasters!),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.priceRules),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  initialValue: day,
                  items: [
                    for (final d in <int?>[null, 0, 1, 2, 3, 4, 5, 6])
                      DropdownMenuItem(value: d, child: Text(weekdayLabel(l10n, d))),
                  ],
                  onChanged: (value) => setState(() => day = value),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${l10n.ruleFrom}: ${formatTime(locale, start)}'),
                  onTap: () async {
                    final picked = await _pickTime(start);
                    if (picked != null) setState(() => start = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${l10n.ruleTo}: ${formatTime(locale, end)}'),
                  onTap: () async {
                    final picked = await _pickTime(end);
                    if (picked != null) setState(() => end = picked);
                  },
                ),
                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.pricePerHour),
                ),
                TextField(
                  controller: half,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.halfCourtPrice),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
          ],
        ),
      ),
    );

    final priceValue = parsePiasters(price.text);
    final halfValue = parsePiasters(half.text);
    price.dispose();
    half.dispose();
    if (saved != true || priceValue == null || !mounted) return;

    final updated = PriceRule(
      dayOfWeek: day,
      startTime: start,
      endTime: end,
      pricePiasters: priceValue,
      halfCourtPiasters: halfValue,
    );
    setState(
      () => _rules = [
        for (var i = 0; i < _rules!.length; i++)
          if (i == index) updated else _rules![i],
        if (index == null) updated,
      ],
    );
  }

  Future<void> _save() async {
    final done = await submit(() => ref.read(ownerCourtRepositoryProvider).setPriceRules(widget.courtId, _rules!));
    if (done && mounted) {
      showSnack(context, context.l10n.pricesSaved);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final rules = _rules;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.priceRules)),
      body: _error != null
          ? ErrorView(error: _error!, onRetry: _load)
          : rules == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text(l10n.priceRulesHint, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
                const SizedBox(height: AppSpacing.s),
                for (var i = 0; i < rules.length; i++)
                  Card(
                    elevation: 0,
                    color: AppColors.gray200,
                    child: ListTile(
                      title: Text(
                        '${weekdayLabel(l10n, rules[i].dayOfWeek)} · ${l10n.timeRange(formatTime(locale, rules[i].startTime), formatTime(locale, rules[i].endTime))}',
                      ),
                      subtitle: Text(formatPricePerHour(l10n, rules[i].pricePiasters)),
                      onTap: () => _edit(rule: rules[i], index: i),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => setState(() => _rules = [...rules]..removeAt(i)),
                      ),
                    ),
                  ),
                OutlinedButton.icon(onPressed: _edit, icon: const Icon(Icons.add), label: Text(l10n.addRule)),
                const SizedBox(height: AppSpacing.l),
                AppButton(label: l10n.save, onPressed: _save, isLoading: isSubmitting),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/owner_controllers.dart';
import '../data/owner_club_repository.dart';
import 'price_rules_screen.dart';

class _Day {
  _Day(this.day, this.closed, this.opens, this.closes);

  final int day;
  bool closed;
  String opens;
  String closes;
}

class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  ConsumerState<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> with SubmitMixin {
  List<_Day>? _days;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final club = await ref.read(ownerClubProvider.future);
      const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      final byDay = {for (final d in club.workingHours) names.indexOf(d.dayOfWeek): d};
      if (!mounted) return;
      setState(
        () => _days = [
          for (var day = 0; day < 7; day++)
            _Day(
              day,
              byDay[day]?.isClosed ?? false,
              byDay[day]?.opensAt ?? '10:00:00',
              byDay[day]?.closesAt ?? '23:00:00',
            ),
        ],
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  // The API wants the hour or the half hour: a picked time snaps to the nearest one.
  Future<String?> _pick(String initial) async {
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
    final time = snapped == 60
        ? TimeOfDay(hour: (picked.hour + 1) % 24, minute: 0)
        : TimeOfDay(hour: picked.hour, minute: snapped);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _save() async {
    final done = await submit(
      () => ref.read(ownerClubRepositoryProvider).setWorkingHours([
        for (final d in _days!) (day: d.day, closed: d.closed, opens: d.opens, closes: d.closes),
      ]),
    );
    if (done && mounted) {
      ref.invalidate(ownerClubProvider);
      showSnack(context, context.l10n.hoursSaved);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final days = _days;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workingHours)),
      body: _error != null
          ? ErrorView(error: _error!, onRetry: _load)
          : days == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                for (final day in days)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 78,
                          child: Text(weekdayLabel(l10n, day.day), style: AppTextStyles.body1Semibold),
                        ),
                        if (day.closed)
                          Expanded(
                            child: Text(l10n.closed, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
                          )
                        else ...[
                          TextButton(
                            onPressed: () async {
                              final picked = await _pick(day.opens);
                              if (picked != null) setState(() => day.opens = picked);
                            },
                            child: Text(formatTime(locale, day.opens)),
                          ),
                          const Text('-'),
                          TextButton(
                            onPressed: () async {
                              final picked = await _pick(day.closes);
                              if (picked != null) setState(() => day.closes = picked);
                            },
                            child: Text(formatTime(locale, day.closes)),
                          ),
                          const Spacer(),
                        ],
                        Switch(
                          value: !day.closed,
                          activeTrackColor: AppColors.primary,
                          onChanged: (open) => setState(() => day.closed = !open),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.l),
                AppButton(label: l10n.save, onPressed: _save, isLoading: isSubmitting),
              ],
            ),
    );
  }
}

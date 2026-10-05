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
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/stepper_field.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../catalog/data/catalog_models.dart';
import '../application/court_booking_controller.dart';
import '../application/recurring_controllers.dart';
import '../data/booking_models.dart';
import '../data/recurring_models.dart';
import '../data/recurring_repository.dart';
import 'booking_labels.dart';
import 'widgets/recurring_card.dart';

// "Every Thursday at 8pm for 8 weeks": check which weeks are free, then book them.
class RecurringBookingScreen extends ConsumerStatefulWidget {
  const RecurringBookingScreen({super.key, required this.courtId});

  final String courtId;

  @override
  ConsumerState<RecurringBookingScreen> createState() => _RecurringBookingScreenState();
}

class _RecurringBookingScreenState extends ConsumerState<RecurringBookingScreen> with SubmitMixin {
  DateTime? _day;
  TimeOfDay? _time;
  int? _duration;
  CourtPart _part = CourtPart.full;
  int _weeks = 4;
  bool _skip = true;
  RecurringPreview? _preview;

  String _hms(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickDay() async {
    final first = today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _setChoice(() => _day = picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 20, minute: 0));
    if (picked == null) return;
    final snapped = picked.minute < 15
        ? 0
        : picked.minute < 45
        ? 30
        : 60;
    setState(
      () => _setChoice(
        () => _time = snapped == 60
            ? TimeOfDay(hour: (picked.hour + 1) % 24, minute: 0)
            : TimeOfDay(hour: picked.hour, minute: snapped),
      ),
    );
  }

  // Changing anything invalidates a preview made before.
  void _setChoice(VoidCallback change) {
    change();
    _preview = null;
  }

  RecurringRequest? _request(CourtDetails court) {
    if (_day == null || _time == null) return null;
    return RecurringRequest(
      courtId: court.id,
      firstDay: apiDay(_day!),
      startTime: _hms(_time!),
      durationMinutes: _duration ?? court.defaultDurationMinutes,
      part: court.allowsHalfCourt ? _part : CourtPart.full,
      weeks: _weeks,
      skipUnavailable: _skip,
      playFormat: PlayFormat.appliesTo(court.sport) ? PlayFormat.doubles : null,
    );
  }

  Future<void> _check(CourtDetails court) async {
    final request = _request(court);
    if (request == null) {
      showMessage('${context.l10n.pickDate} / ${context.l10n.pickTime}');
      return;
    }
    await submit(() async {
      final preview = await ref.read(recurringRepositoryProvider).preview(request);
      if (mounted) setState(() => _preview = preview);
    });
  }

  Future<void> _book(CourtDetails court) async {
    final request = _request(court)!;
    final done = await submit(() => ref.read(recurringRepositoryProvider).create(request));
    if (done && mounted) {
      ref.invalidate(myRecurringProvider);
      showMessage(context.l10n.recurringCreated);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final court = ref.watch(courtProvider(widget.courtId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      body: court.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(courtProvider(widget.courtId)),
        ),
        data: (court) {
          final preview = _preview;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('${court.club.name} · ${court.name}', style: AppTextStyles.header),
              const SizedBox(height: AppSpacing.m),
              PickerField(
                label: l10n.firstDay,
                hint: l10n.pickDate,
                value: _day == null ? null : formatLongDay(locale, _day!),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDay,
              ),
              const SizedBox(height: AppSpacing.m),
              PickerField(
                label: l10n.timeLabel,
                hint: l10n.pickTime,
                value: _time == null ? null : formatTime(locale, _hms(_time!)),
                icon: Icons.schedule_outlined,
                onTap: _pickTime,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(l10n.duration, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              ChoiceChips<int>(
                options: court.allowedDurations,
                selected: _duration ?? court.defaultDurationMinutes,
                labelOf: (m) => l10n.minutesLabel(m),
                onSelected: (m) => setState(() => _setChoice(() => _duration = m)),
              ),
              if (court.allowsHalfCourt) ...[
                const SizedBox(height: AppSpacing.m),
                Text(l10n.courtPartLabel, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                ChoiceChips<CourtPart>(
                  options: CourtPart.values,
                  selected: _part,
                  labelOf: (p) => p.label(l10n),
                  onSelected: (p) => setState(() => _setChoice(() => _part = p)),
                ),
              ],
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(child: Text(l10n.weeksCount, style: AppTextStyles.title)),
                  StepperField(
                    value: _weeks,
                    min: 2,
                    max: 52,
                    onChanged: (v) => setState(() => _setChoice(() => _weeks = v)),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.skipUnavailable),
                value: _skip,
                onChanged: (v) => setState(() => _setChoice(() => _skip = v)),
              ),
              const SizedBox(height: AppSpacing.s),
              AppButton(
                label: l10n.previewWeeks,
                style: AppButtonStyle.outlined,
                isLoading: isSubmitting && preview == null,
                onPressed: () => _check(court),
              ),
              if (preview != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  l10n.availableWeeksTotal(preview.availableWeeks, formatPounds(preview.totalPiasters)),
                  style: AppTextStyles.body1Semibold,
                ),
                for (final week in preview.weeks)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      week.isAvailable ? Icons.check_circle : Icons.cancel,
                      color: week.isAvailable ? AppColors.primary : AppColors.error,
                    ),
                    title: Text(formatLongDay(locale, parseApiDay(week.day))),
                    trailing: Text(
                      week.isAvailable ? l10n.weekAvailable : l10n.weekTaken,
                      style: AppTextStyles.caption,
                    ),
                  ),
                const SizedBox(height: AppSpacing.s),
                AppButton(
                  label: l10n.confirmRecurring,
                  isLoading: isSubmitting,
                  onPressed: preview.availableWeeks == 0 || (!_skip && preview.availableWeeks < preview.weeks.length)
                      ? null
                      : () => _book(court),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class MyRecurringScreen extends ConsumerWidget {
  const MyRecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRecurring)),
      body: PagedListView<RecurringBooking>(
        state: myRecurringProvider,
        actions: myRecurringProvider.notifier,
        emptyMessage: l10n.noRecurring,
        emptyIcon: Icons.repeat,
        separator: const SizedBox(height: AppSpacing.s),
        itemBuilder: (context, booking) => RecurringCard(
          booking: booking,
          actions: [
            if (booking.canCancel)
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(recurringRepositoryProvider).cancel(booking.id);
                    ref.invalidate(myRecurringProvider);
                    if (context.mounted) showSnack(context, l10n.recurringCancelled);
                  } on ApiException catch (e) {
                    if (context.mounted) showApiError(context, e);
                  }
                },
                child: Text(l10n.cancelRecurring, style: TextStyle(color: AppColors.error)),
              ),
          ],
        ),
      ),
    );
  }
}

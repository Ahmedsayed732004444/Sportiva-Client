import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../../core/widgets/stepper_field.dart';
import '../../booking/application/recurring_controllers.dart';
import '../../booking/data/booking_models.dart';
import '../../booking/data/recurring_models.dart';
import '../../booking/data/recurring_repository.dart';
import '../../booking/presentation/booking_labels.dart';
import '../application/owner_controllers.dart';
import '../data/owner_booking_repository.dart';
import '../data/owner_court_models.dart';

// A booking the club records for a phone call or a walk-in.
class ManualBookingScreen extends ConsumerStatefulWidget {
  const ManualBookingScreen({super.key});

  @override
  ConsumerState<ManualBookingScreen> createState() => _ManualBookingScreenState();
}

class _ManualBookingScreenState extends ConsumerState<ManualBookingScreen> with SubmitMixin {
  static const _durations = [60, 90, 120];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  OwnerCourt? _court;
  DateTime? _day;
  TimeOfDay? _time;
  int _duration = 60;
  CourtPart _part = CourtPart.full;
  PlayFormat? _format;
  bool _weekly = false;
  int _weeks = 4;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _email]) {
      controller.dispose();
    }
    super.dispose();
  }

  String _hms(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickDay() async {
    final first = today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0));
    if (picked == null) return;
    final snapped = picked.minute < 15
        ? 0
        : picked.minute < 45
        ? 30
        : 60;
    setState(
      () => _time = snapped == 60
          ? TimeOfDay(hour: (picked.hour + 1) % 24, minute: 0)
          : TimeOfDay(hour: picked.hour, minute: snapped),
    );
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_court == null || _day == null || _time == null) {
      showMessage('${l10n.selectCourt} / ${l10n.pickDate} / ${l10n.pickTime}');
      return;
    }

    if (_weekly) {
      final request = RecurringRequest(
        courtId: _court!.id,
        firstDay: apiDay(_day!),
        startTime: _hms(_time!),
        durationMinutes: _duration,
        part: _court!.allowsHalfCourt ? _part : CourtPart.full,
        weeks: _weeks,
        skipUnavailable: true,
        playFormat: _court!.hasPlayFormat ? (_format ?? PlayFormat.doubles) : null,
      );
      final created = await submit(
        () => ref
            .read(recurringRepositoryProvider)
            .createManual(
              request,
              customerName: _name.text.trim().isEmpty ? null : _name.text.trim(),
              customerPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              userEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
            ),
      );
      if (created && mounted) {
        ref.invalidate(clubRecurringProvider);
        showMessage(l10n.recurringCreated);
        context.pop();
      }
      return;
    }

    final done = await submit(
      () => ref
          .read(ownerBookingRepositoryProvider)
          .createManual(
            courtId: _court!.id,
            day: _day!,
            startTime: _hms(_time!),
            durationMinutes: _duration,
            part: _court!.allowsHalfCourt ? _part : CourtPart.full,
            playFormat: _court!.hasPlayFormat ? (_format ?? PlayFormat.doubles) : null,
            customerName: _name.text.trim().isEmpty ? null : _name.text.trim(),
            customerPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            userEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
          ),
    );

    if (done && mounted) {
      ref.invalidate(upcomingOwnerBookingsProvider);
      ref.invalidate(pendingOwnerBookingsProvider);
      showMessage(l10n.bookingCreated);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final validators = Validators(l10n);
    final courts = ref.watch(ownerCourtsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualBooking)),
      body: courts.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          error: const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(ownerCourtsProvider),
        ),
        data: (courts) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text(l10n.selectCourt, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<OwnerCourt>(
                initialValue: _court,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: [
                  for (final court in courts.where((c) => c.isActive))
                    DropdownMenuItem(value: court, child: Text('${court.name} · ${court.sport.label(l10n)}')),
                ],
                onChanged: (court) => setState(() {
                  _court = court;
                  _part = CourtPart.full;
                }),
              ),
              const SizedBox(height: AppSpacing.m),
              PickerField(
                label: l10n.dateLabel,
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
                options: _durations,
                selected: _duration,
                labelOf: (m) => l10n.minutesLabel(m),
                onSelected: (m) => setState(() => _duration = m),
              ),
              if (_court?.allowsHalfCourt ?? false) ...[
                const SizedBox(height: AppSpacing.m),
                Text(l10n.courtPartLabel, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                ChoiceChips<CourtPart>(
                  options: CourtPart.values,
                  selected: _part,
                  labelOf: (p) => p.label(l10n),
                  onSelected: (p) => setState(() => _part = p),
                ),
              ],
              if (_court?.hasPlayFormat ?? false) ...[
                const SizedBox(height: AppSpacing.m),
                Text(l10n.playFormatLabel, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                ChoiceChips<PlayFormat>(
                  options: PlayFormat.values,
                  selected: _format ?? PlayFormat.doubles,
                  labelOf: (f) => f.label(l10n),
                  onSelected: (f) => setState(() => _format = f),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.repeatWeekly),
                value: _weekly,
                onChanged: (v) => setState(() => _weekly = v),
              ),
              if (_weekly)
                Row(
                  children: [
                    Expanded(child: Text(l10n.weeksCount, style: AppTextStyles.title)),
                    StepperField(value: _weeks, min: 2, max: 52, onChanged: (v) => setState(() => _weeks = v)),
                  ],
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.repeatWeekly),
                value: _weekly,
                onChanged: (v) => setState(() => _weekly = v),
              ),
              if (_weekly)
                Row(
                  children: [
                    Expanded(child: Text(l10n.weeksCount, style: AppTextStyles.title)),
                    StepperField(value: _weeks, min: 2, max: 52, onChanged: (v) => setState(() => _weeks = v)),
                  ],
                ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(label: l10n.customerName, hint: l10n.customerName, controller: _name),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: l10n.customerPhone,
                hint: l10n.enterPhone,
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: (value) => (value ?? '').trim().isEmpty ? null : validators.phone(value),
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: l10n.customerEmail,
                hint: l10n.customerEmail,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: (value) => (value ?? '').trim().isEmpty ? null : validators.email(value),
              ),
              const SizedBox(height: AppSpacing.l),
              AppButton(label: l10n.manualBooking, onPressed: _create, isLoading: isSubmitting),
            ],
          ),
        ),
      ),
    );
  }
}

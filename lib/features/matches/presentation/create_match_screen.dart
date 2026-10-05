import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/stepper_field.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../catalog/data/sport_type.dart';
import '../application/matches_controller.dart';
import '../data/match_repository.dart';

// A match at a place of the organizer's choice. (A match on a club's court is opened from the booking.)
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> with SubmitMixin {
  static const _durations = [60, 90, 120];

  final _formKey = GlobalKey<FormState>();
  final _place = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();

  // On a club's court (the court is picked on its own screen) or at a place the organizer names.
  bool _onCourt = false;
  SportType _sport = SportType.football;
  DateTime? _day;
  TimeOfDay? _time;
  int _duration = 60;
  int _players = 4;
  int? _governorateId;

  @override
  void dispose() {
    for (final controller in [_place, _city, _address, _note]) {
      controller.dispose();
    }
    super.dispose();
  }

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

  // The API wants the hour or the half hour: the picked time snaps to the nearest one.
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

  String _hms(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  Future<void> _create() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_day == null || _time == null) {
      showMessage('${l10n.pickDate} / ${l10n.pickTime}');
      return;
    }

    String? matchId;
    final done = await submit(() async {
      final match = await ref
          .read(matchRepositoryProvider)
          .createOutside(
            sport: _sport,
            day: _day!,
            startTime: _hms(_time!),
            durationMinutes: _duration,
            playersNeeded: _players,
            placeName: _place.text.trim(),
            address: _address.text.trim(),
            governorateId: _governorateId!,
            city: _city.text.trim(),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      matchId = match.id;
    });

    if (done && mounted) {
      showMessage(l10n.matchCreated);
      ref.invalidate(myMatchesProvider);
      ref.invalidate(openMatchesProvider);
      context.pushReplacement('/match/$matchId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final validators = Validators(l10n);
    final governorates = ref.watch(governoratesProvider);

    return AuthScaffold(
      title: l10n.createMatch,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChoiceChips<bool>(
              options: const [true, false],
              selected: _onCourt,
              labelOf: (onCourt) => onCourt ? l10n.matchOnCourt : l10n.matchOnOutside,
              onSelected: (onCourt) => setState(() => _onCourt = onCourt),
            ),
            const SizedBox(height: AppSpacing.m),
            if (_onCourt) ...[
              Text(l10n.chooseCourtForMatch, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
              const SizedBox(height: AppSpacing.l),
              AppButton(label: l10n.pickCourtButton, onPressed: () => context.push('/matches/pick-court')),
            ] else ...[
              Text(l10n.sport, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              ChoiceChips<SportType>(
                options: SportType.values.where((s) => s != SportType.other).toList(),
                selected: _sport,
                labelOf: (s) => s.label(l10n),
                onSelected: (s) => setState(() => _sport = s),
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
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(child: Text(l10n.playersNeeded, style: AppTextStyles.title)),
                  StepperField(value: _players, onChanged: (v) => setState(() => _players = v)),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: l10n.placeName,
                hint: l10n.enterPlaceName,
                controller: _place,
                validator: validators.required,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(l10n.governorate, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<int>(
                initialValue: _governorateId,
                isExpanded: true,
                validator: (value) => value == null ? l10n.fieldRequired : null,
                decoration: const InputDecoration(),
                style: AppTextStyles.body1,
                items: [
                  for (final g in governorates.valueOrNull ?? const [])
                    DropdownMenuItem(value: g.id, child: Text(g.name(locale))),
                ],
                onChanged: (value) => setState(() => _governorateId = value),
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(label: l10n.city, hint: l10n.enterCity, controller: _city, validator: validators.required),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: l10n.address,
                hint: l10n.address,
                controller: _address,
                validator: validators.required,
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: l10n.note,
                hint: l10n.enterNote,
                controller: _note,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.l),
              AppButton(label: l10n.createMatch, onPressed: _create, isLoading: isSubmitting),
            ],
          ],
        ),
      ),
    );
  }
}

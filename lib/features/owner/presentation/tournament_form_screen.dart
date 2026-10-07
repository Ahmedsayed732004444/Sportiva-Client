import '../../../core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/stepper_field.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../catalog/data/sport_type.dart';
import '../../tournaments/data/tournament_models.dart';
import '../../tournaments/presentation/tournament_labels.dart';
import '../application/owner_controllers.dart';
import '../application/owner_tournament_controllers.dart';
import '../data/owner_tournament_repository.dart';

class TournamentFormScreen extends ConsumerStatefulWidget {
  const TournamentFormScreen({super.key});

  @override
  ConsumerState<TournamentFormScreen> createState() => _TournamentFormScreenState();
}

class _TournamentFormScreenState extends ConsumerState<TournamentFormScreen> with SubmitMixin {
  XFile? _poster;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _rules = TextEditingController();
  final _prizes = TextEditingController();
  final _fee = TextEditingController(text: '0');

  SportType _sport = SportType.football;
  TournamentFormat _format = TournamentFormat.knockout;
  bool _individual = false;
  int _players = 5;
  int _subs = 2;
  int _maxTeams = 8;
  int _groups = 2;
  int _qualifiers = 2;
  int _matchMinutes = 60;
  DateTime? _closes;
  DateTime? _start;
  DateTime? _end;
  TimeOfDay _dailyStart = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _dailyEnd = const TimeOfDay(hour: 22, minute: 0);
  final _courts = <String>{};

  @override
  void dispose() {
    for (final controller in [_name, _description, _rules, _prizes, _fee]) {
      controller.dispose();
    }
    super.dispose();
  }

  String _hms(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  Future<DateTime?> _pickDay(DateTime? current, {DateTime? from}) {
    final first = from ?? today();
    return showDatePicker(
      context: context,
      initialDate: current ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
  }

  // The API wants the hour or the half hour: a picked time snaps to the nearest one.
  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return null;
    final snapped = picked.minute < 15
        ? 0
        : picked.minute < 45
        ? 30
        : 60;
    return snapped == 60
        ? TimeOfDay(hour: (picked.hour + 1) % 24, minute: 0)
        : TimeOfDay(hour: picked.hour, minute: snapped);
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_closes == null || _start == null || _end == null) {
      showMessage('${l10n.registrationCloseLabel} / ${l10n.startDateLabel} / ${l10n.endDateLabel}');
      return;
    }
    if (_courts.isEmpty) {
      showMessage(l10n.mustPickCourt);
      return;
    }

    String? orNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final form = TournamentForm(
      name: _name.text.trim(),
      description: orNull(_description),
      rules: orNull(_rules),
      prizes: orNull(_prizes),
      sport: _sport,
      format: _format,
      isIndividual: _individual,
      playersPerTeam: _players,
      substitutesPerTeam: _subs,
      maxTeams: _maxTeams,
      groupsCount: _groups,
      qualifiersPerGroup: _qualifiers,
      feePiasters: parsePiasters(_fee.text) ?? 0,
      // Registration closes at the end of the picked day.
      registrationClosesAt: DateTime(_closes!.year, _closes!.month, _closes!.day, 23, 30),
      startDate: _start!,
      endDate: _end!,
      dailyStartTime: _hms(_dailyStart),
      dailyEndTime: _hms(_dailyEnd),
      matchMinutes: _matchMinutes,
      courtIds: _courts.toList(),
    );

    String? id;
    final poster = _poster;
    final done = await submit(() async {
      final repository = ref.read(ownerTournamentRepositoryProvider);
      id = await repository.create(form);
      if (poster != null) await repository.setPoster(id!, poster.path);
    });
    if (done && mounted) {
      ref.invalidate(ownerTournamentsProvider);
      showMessage(l10n.tournamentCreated);
      context.pushReplacement('/owner/tournament/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final courts = (ref.watch(ownerCourtsProvider).valueOrNull ?? const []).where((c) => c.sport == _sport).toList();

    Widget labelled(String label, Widget child) => Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.title)),
        child,
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTournament)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            AppTextField(
              label: l10n.tournamentName,
              hint: l10n.enterTournamentName,
              controller: _name,
              validator: (v) => (v ?? '').trim().length < 3 ? l10n.nameTooShort : null,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.posterOptional, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 1920,
                );
                if (picked != null) setState(() => _poster = picked);
              },
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: _poster == null
                      ? ColoredBox(
                          color: AppColors.gray200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary),
                              Text(l10n.pickPosterNow, style: AppTextStyles.body2),
                            ],
                          ),
                        )
                      : Image.file(File(_poster!.path), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.sport, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            ChoiceChips<SportType>(
              options: SportType.values.where((s) => s != SportType.other).toList(),
              selected: _sport,
              labelOf: (s) => s.label(l10n),
              onSelected: (s) => setState(() {
                _sport = s;
                _courts.clear();
              }),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.tournamentFormat, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            ChoiceChips<TournamentFormat>(
              options: TournamentFormat.values,
              selected: _format,
              labelOf: (f) => f.label(l10n),
              onSelected: (f) => setState(() => _format = f),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.individualSwitch),
              value: _individual,
              onChanged: (v) => setState(() => _individual = v),
            ),
            if (!_individual) ...[
              labelled(
                l10n.playersPerTeamLabel,
                StepperField(value: _players, min: 1, max: 30, onChanged: (v) => setState(() => _players = v)),
              ),
              labelled(
                l10n.substitutesLabel,
                StepperField(value: _subs, min: 0, max: 20, onChanged: (v) => setState(() => _subs = v)),
              ),
            ],
            labelled(
              l10n.maxTeamsLabel,
              StepperField(value: _maxTeams, min: 2, max: 128, onChanged: (v) => setState(() => _maxTeams = v)),
            ),
            if (_format == TournamentFormat.groupsKnockout) ...[
              labelled(
                l10n.groupsCountLabel,
                StepperField(value: _groups, min: 2, max: 16, onChanged: (v) => setState(() => _groups = v)),
              ),
              labelled(
                l10n.qualifiersLabel,
                StepperField(value: _qualifiers, min: 1, max: 4, onChanged: (v) => setState(() => _qualifiers = v)),
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.entryFee,
              hint: '0',
              controller: _fee,
              keyboardType: TextInputType.number,
              validator: (v) => parsePiasters(v ?? '') == null ? l10n.invalidNumber : null,
            ),
            const SizedBox(height: AppSpacing.m),
            PickerField(
              label: l10n.registrationCloseLabel,
              hint: l10n.pickDate,
              value: _closes == null ? null : formatLongDay(locale, _closes!),
              icon: Icons.event_available_outlined,
              onTap: () async {
                final picked = await _pickDay(_closes);
                if (picked != null) setState(() => _closes = picked);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            PickerField(
              label: l10n.startDateLabel,
              hint: l10n.pickDate,
              value: _start == null ? null : formatLongDay(locale, _start!),
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                final picked = await _pickDay(_start);
                if (picked != null) setState(() => _start = picked);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            PickerField(
              label: l10n.endDateLabel,
              hint: l10n.pickDate,
              value: _end == null ? null : formatLongDay(locale, _end!),
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                final picked = await _pickDay(_end, from: _start);
                if (picked != null) setState(() => _end = picked);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            PickerField(
              label: l10n.dailyStartLabel,
              value: formatTime(locale, _hms(_dailyStart)),
              icon: Icons.schedule_outlined,
              onTap: () async {
                final picked = await _pickTime(_dailyStart);
                if (picked != null) setState(() => _dailyStart = picked);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            PickerField(
              label: l10n.dailyEndLabel,
              value: formatTime(locale, _hms(_dailyEnd)),
              icon: Icons.schedule_outlined,
              onTap: () async {
                final picked = await _pickTime(_dailyEnd);
                if (picked != null) setState(() => _dailyEnd = picked);
              },
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.matchMinutesLabel, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            ChoiceChips<int>(
              options: const [30, 60, 90, 120],
              selected: _matchMinutes,
              labelOf: (m) => l10n.minutesLabel(m),
              onSelected: (m) => setState(() => _matchMinutes = m),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(l10n.pickCourts, style: AppTextStyles.title),
            Wrap(
              spacing: 8,
              children: [
                for (final court in courts)
                  FilterChip(
                    label: Text(court.name),
                    selected: _courts.contains(court.id),
                    onSelected: (on) => setState(() => on ? _courts.add(court.id) : _courts.remove(court.id)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(label: l10n.description, hint: l10n.description, controller: _description),
            const SizedBox(height: AppSpacing.m),
            AppTextField(label: l10n.rulesField, hint: l10n.rules, controller: _rules),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              label: l10n.prizesField,
              hint: l10n.prizes,
              controller: _prizes,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(label: l10n.createTournament, onPressed: _create, isLoading: isSubmitting),
          ],
        ),
      ),
    );
  }
}

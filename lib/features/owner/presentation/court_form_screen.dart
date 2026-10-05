import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../catalog/data/sport_type.dart';
import '../application/owner_controllers.dart';
import '../data/owner_court_models.dart';
import '../data/owner_court_repository.dart';

// Adds a court, or edits the one with [courtId].
class CourtFormScreen extends ConsumerStatefulWidget {
  const CourtFormScreen({super.key, this.courtId});

  final String? courtId;

  @override
  ConsumerState<CourtFormScreen> createState() => _CourtFormScreenState();
}

class _CourtFormScreenState extends ConsumerState<CourtFormScreen> with SubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _halfPrice = TextEditingController();
  final _timeout = TextEditingController(text: '60');

  SportType _sport = SportType.football;
  ConfirmationMode _mode = ConfirmationMode.manual;
  bool _half = false;
  bool _loaded = false;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    if (widget.courtId == null) {
      _loaded = true;
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _description, _price, _halfPrice, _timeout]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final court = await ref.read(ownerCourtRepositoryProvider).get(widget.courtId!);
      if (!mounted) return;
      setState(() {
        _name.text = court.name;
        _description.text = court.description ?? '';
        _price.text = formatPounds(court.pricePiasters);
        _halfPrice.text = court.halfCourtPiasters == null ? '' : formatPounds(court.halfCourtPiasters!);
        _timeout.text = '${court.responseTimeoutMinutes ?? 60}';
        _sport = court.sport;
        _mode = court.confirmationMode;
        _half = court.allowsHalfCourt;
        _loaded = true;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final form = CourtForm(
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      sport: _sport,
      confirmationMode: _mode,
      responseTimeoutMinutes: int.tryParse(_timeout.text.trim()),
      pricePiasters: parsePiasters(_price.text)!,
      allowsHalfCourt: _half,
      halfCourtPiasters: _half ? parsePiasters(_halfPrice.text) : null,
    );
    final repository = ref.read(ownerCourtRepositoryProvider);

    final done = await submit(
      () => widget.courtId == null ? repository.create(form) : repository.update(widget.courtId!, form),
    );
    if (done && mounted) {
      ref.invalidate(ownerCourtsProvider);
      showMessage(context.l10n.courtSaved);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String? number(String? value) => parsePiasters(value ?? '') == null ? l10n.invalidNumber : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.courtId == null ? l10n.addCourt : l10n.editCourt)),
      body: _error != null
          ? ErrorView(error: _error!, onRetry: _load)
          : !_loaded
          ? const LoadingView()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  AppTextField(
                    label: l10n.courtName,
                    hint: l10n.enterCourtName,
                    controller: _name,
                    validator: (v) => (v ?? '').trim().length < 2 ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(l10n.sport, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  ChoiceChips<SportType>(
                    options: SportType.values.where((s) => s != SportType.other).toList(),
                    selected: _sport,
                    labelOf: (s) => s.label(l10n),
                    onSelected: (s) => setState(() => _sport = s),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: l10n.pricePerHour,
                    hint: l10n.enterPrice,
                    controller: _price,
                    keyboardType: TextInputType.number,
                    validator: number,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.allowsHalfCourt),
                    value: _half,
                    onChanged: (value) => setState(() => _half = value),
                  ),
                  if (_half) ...[
                    AppTextField(
                      label: l10n.halfCourtPrice,
                      hint: l10n.enterPrice,
                      controller: _halfPrice,
                      keyboardType: TextInputType.number,
                      validator: number,
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  Text(l10n.confirmationMode, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  ChoiceChips<ConfirmationMode>(
                    options: ConfirmationMode.values,
                    selected: _mode,
                    labelOf: (m) => m == ConfirmationMode.manual ? l10n.modeManual : l10n.modeAutomatic,
                    onSelected: (m) => setState(() => _mode = m),
                  ),
                  if (_mode == ConfirmationMode.manual) ...[
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      label: l10n.responseTimeout,
                      hint: '60',
                      controller: _timeout,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final minutes = int.tryParse((v ?? '').trim());
                        return minutes == null || minutes < 5 ? l10n.invalidNumber : null;
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: l10n.description,
                    hint: l10n.description,
                    controller: _description,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppButton(label: l10n.save, onPressed: _save, isLoading: isSubmitting),
                ],
              ),
            ),
    );
  }
}

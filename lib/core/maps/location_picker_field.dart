import 'package:flutter/material.dart';

import '../localization/l10n_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'map_picker_screen.dart';

// A form field for a place: the person picks it on the map instead of pasting a Google Maps link. The value kept in
// [controller] is still a maps link, the format the API reads. [onAddress] gets the picked place's address.
class LocationPickerField extends StatefulWidget {
  const LocationPickerField({super.key, required this.label, required this.controller, this.onAddress});

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onAddress;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  Future<void> _pick() async {
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: PickedLocation.fromMapUrl(widget.controller.text))),
    );
    if (picked == null || !mounted) return;
    setState(() => widget.controller.text = picked.mapUrl);
    if (picked.address != null) widget.onAddress?.call(picked.address!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = PickedLocation.fromMapUrl(widget.controller.text);
    final hasValue = widget.controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          onPressed: _pick,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSpacing.fieldHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
            side: BorderSide(color: hasValue ? AppColors.primary : AppColors.gray400),
          ),
          icon: Icon(hasValue ? Icons.where_to_vote : Icons.map_outlined, color: AppColors.primary),
          label: Text(
            hasValue
                ? (current == null
                      ? l10n.locationPicked
                      : '${l10n.locationPicked} · ${current.latitude.toStringAsFixed(4)}, ${current.longitude.toStringAsFixed(4)}')
                : l10n.pickOnMap,
            style: AppTextStyles.body1.copyWith(color: hasValue ? AppColors.primary : AppColors.ink),
          ),
        ),
      ],
    );
  }
}

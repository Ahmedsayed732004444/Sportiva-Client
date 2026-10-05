import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/booking_models.dart';
import '../booking_labels.dart';

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip(this.status, {super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label(context.l10n),
        style: AppTextStyles.caption.copyWith(color: status.color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../catalog/data/sport_type.dart';

// The sports at the top of the home. Tapping one opens the page with that sport's courts.
class SportsRow extends StatelessWidget {
  const SportsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          for (final sport in SportType.homeSports) ...[
            Expanded(
              child: _SportTile(sport: sport, onTap: () => context.push('/courts?sport=${sport.apiName}')),
            ),
            if (sport != SportType.homeSports.last) const SizedBox(width: AppSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({required this.sport, required this.onTap});

  final SportType sport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Column(
          children: [
            Icon(sport.icon, size: 36, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              sport.label(context.l10n),
              style: AppTextStyles.body2.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

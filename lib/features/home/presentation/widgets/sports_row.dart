import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../catalog/data/sport_type.dart';
import '../../application/home_controller.dart';

// The sports at the top of the home. Tapping one shows its nearest courts; tapping it again clears it.
class SportsRow extends ConsumerWidget {
  const SportsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSportProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          for (final sport in SportType.homeSports) ...[
            Expanded(
              child: _SportTile(
                sport: sport,
                selected: sport == selected,
                onTap: () => ref.read(selectedSportProvider.notifier).state = sport == selected ? null : sport,
              ),
            ),
            if (sport != SportType.homeSports.last) const SizedBox(width: AppSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({required this.sport, required this.selected, required this.onTap});

  final SportType sport;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.primary;

    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.primary : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Column(
          children: [
            Icon(sport.icon, size: 36, color: foreground),
            const SizedBox(height: AppSpacing.xs),
            Text(
              sport.label(context.l10n),
              style: AppTextStyles.body2.copyWith(
                color: selected ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

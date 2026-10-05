import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../catalog/data/catalog_models.dart';

class CourtCard extends StatelessWidget {
  const CourtCard({
    super.key,
    required this.court,
    this.onTap,
    this.width = defaultWidth,
    this.imageAspectRatio = 16 / 9,
  });

  final CourtListItem court;
  final VoidCallback? onTap;

  static const defaultWidth = 240.0;

  final double width;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AppNetworkImage(url: court.imageUrl, icon: court.sport.icon),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(court.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body1Semibold),
                  Text(
                    court.club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(color: AppColors.black600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (court.distanceText != null) ...[
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryMid),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            court.distanceText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      StarRating(rating: court.averageRating, count: court.reviewsCount, size: 14),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPricePerHour(l10n, court.pricePerHourPiasters),
                    style: AppTextStyles.body2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

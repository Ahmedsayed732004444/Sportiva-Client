import '../../../../core/widgets/image_carousel.dart';
import '../../../../core/widgets/distance_badge.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/club_logo.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../catalog/data/catalog_models.dart';

class ClubCard extends StatelessWidget {
  const ClubCard({super.key, required this.club, this.onTap});

  final ClubListItem club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final place = [club.city, club.governorateName].whereType<String>().where((s) => s.isNotEmpty).join('، ');

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageCarousel(urls: club.gallery, icon: Icons.storefront_outlined),
                  PositionedDirectional(start: 8, bottom: 8, child: ClubLogo(url: club.logoUrl, radius: 16)),
                  PositionedDirectional(end: 8, top: 8, child: DistanceBadge(km: club.distanceKm)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        club.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StarRating(rating: club.averageRating, count: club.reviewsCount),
                  ],
                ),
                if (place.isNotEmpty)
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(color: AppColors.black600),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    for (final sport in club.sports.toSet())
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: Icon(sport.icon, size: 18, color: AppColors.primary),
                      ),
                    Text(
                      l10n.courtsCount(club.courtsCount),
                      style: AppTextStyles.caption.copyWith(color: AppColors.black600),
                    ),
                    const Spacer(),
                    if (club.distanceText != null) ...[
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryMid),
                      Text(club.distanceText!, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

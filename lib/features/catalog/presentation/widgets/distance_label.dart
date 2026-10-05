import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/location/distance.dart';
import '../../../../core/location/location_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// "3.2 km away": how far a club is from where the user is. Nothing is shown when either place is unknown.
class DistanceLabel extends ConsumerWidget {
  const DistanceLabel({super.key, required this.latitude, required this.longitude});

  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(locationProvider).valueOrNull?.position;
    if (position == null || latitude == null || longitude == null) return const SizedBox.shrink();

    final km = distanceKm(position, latitude!, longitude!);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.near_me_outlined, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(context.l10n.distanceAway(kmLabel(km)), style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
      ],
    );
  }
}

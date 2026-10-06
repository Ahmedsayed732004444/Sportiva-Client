import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// A club's logo as a small round badge with a light ring, so it reads on top of a picture too.
class ClubLogo extends StatelessWidget {
  const ClubLogo({super.key, required this.url, this.radius = 16});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final address = url;
    final hasLogo = address != null && address.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gray200),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.gray200,
        backgroundImage: hasLogo ? CachedNetworkImageProvider(address) : null,
        child: hasLogo ? null : Icon(Icons.storefront_outlined, size: radius, color: AppColors.gray500),
      ),
    );
  }
}

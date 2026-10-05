import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// A person's picture, or their first letter on the brand colour when they have none.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.url, this.radius = 20});

  final String name;
  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final address = url;
    final hasPicture = address != null && address.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      backgroundImage: hasPicture ? CachedNetworkImageProvider(address) : null,
      child: hasPicture
          ? null
          : Text(
              name.isEmpty ? '?' : name.characters.first,
              style: TextStyle(color: AppColors.onBrand, fontSize: radius * 0.8),
            ),
    );
  }
}

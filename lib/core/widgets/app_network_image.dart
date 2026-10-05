import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// A picture from the API with a quiet placeholder while it loads, and when it is missing or fails.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({super.key, required this.url, this.icon = Icons.sports});

  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: AppColors.gray200,
      child: Center(child: Icon(icon, color: AppColors.gray400, size: 36)),
    );

    final address = url;
    if (address == null || address.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: address,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_network_image.dart';

// Pictures the user swipes through, with dots under them. One picture (or none) shows without dots.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key, required this.urls, this.icon = Icons.sports});

  final List<String> urls;
  final IconData icon;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    if (urls.length < 2) return AppNetworkImage(url: urls.isEmpty ? null : urls.first, icon: widget.icon);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: urls.length,
          onPageChanged: (index) => setState(() => _page = index),
          itemBuilder: (_, index) => AppNetworkImage(url: urls[index], icon: widget.icon),
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 8,
          child: IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < urls.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: i == _page ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.onBrand : AppColors.onBrand.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n_extension.dart';
import '../../core/widgets/app_bottom_nav.dart';

// The frame around the five main tabs. Each tab keeps its own state while you switch.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.navHome),
      AppNavItem(icon: Icons.sports_soccer_outlined, activeIcon: Icons.sports_soccer, label: l10n.navMatches),
      AppNavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: l10n.navSocial),
      AppNavItem(icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: l10n.navBookings),
      AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.navProfile),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        items: items,
        currentIndex: navigationShell.currentIndex,
        // Tapping the current tab goes back to its first screen.
        onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}

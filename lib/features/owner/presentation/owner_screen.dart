import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extension.dart';
import 'club_tab.dart';
import 'owner_bookings_tab.dart';
import 'owner_courts_tab.dart';
import 'owner_tournaments_tab.dart';

// The club's side of the app: its bookings, courts, tournaments and its own settings.
class OwnerScreen extends StatefulWidget {
  const OwnerScreen({super.key});

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.ownerBookings, l10n.ownerCourts, l10n.ownerTournaments, l10n.ownerClub];

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.ownerTitle} · ${titles[_index]}')),
      body: IndexedStack(
        index: _index,
        children: const [OwnerBookingsTab(), OwnerCourtsTab(), OwnerTournamentsTab(), ClubTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: l10n.ownerBookings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_tennis_outlined),
            selectedIcon: const Icon(Icons.sports_tennis),
            label: l10n.ownerCourts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: l10n.ownerTournaments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.ownerClub,
          ),
        ],
      ),
    );
  }
}

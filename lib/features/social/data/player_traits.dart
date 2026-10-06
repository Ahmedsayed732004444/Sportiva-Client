import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum PlayerPosition {
  goalkeeper('Goalkeeper', Icons.sports_handball),
  defender('Defender', Icons.shield_outlined),
  midfielder('Midfielder', Icons.swap_horiz),
  forward('Forward', Icons.sports_soccer);

  const PlayerPosition(this.apiName, this.icon);

  final String apiName;
  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    goalkeeper => l10n.positionGoalkeeper,
    defender => l10n.positionDefender,
    midfielder => l10n.positionMidfielder,
    forward => l10n.positionForward,
  };

  static PlayerPosition? fromApi(Object? value) {
    for (final position in values) {
      if (position.apiName == value?.toString()) return position;
    }
    return null;
  }
}

enum PreferredFoot {
  right('Right'),
  left('Left'),
  both('Both');

  const PreferredFoot(this.apiName);

  final String apiName;

  String label(AppLocalizations l10n) => switch (this) {
    right => l10n.footRight,
    left => l10n.footLeft,
    both => l10n.footBoth,
  };

  static PreferredFoot? fromApi(Object? value) {
    for (final foot in values) {
      if (foot.apiName == value?.toString()) return foot;
    }
    return null;
  }
}

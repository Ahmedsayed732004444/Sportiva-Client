import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum SportType {
  football('Football', Icons.sports_soccer),
  padel('Padel', Icons.sports_tennis),
  tennis('Tennis', Icons.sports_tennis),
  basketball('Basketball', Icons.sports_basketball),
  volleyball('Volleyball', Icons.sports_volleyball),
  other('Other', Icons.sports);

  const SportType(this.apiName, this.icon);

  // The name the API uses in JSON and in filters (SportTypeDto).
  final String apiName;
  final IconData icon;

  // The sports offered on the home, in order: change the list to change the home.
  static const homeSports = [football, padel, basketball];

  String label(AppLocalizations l10n) => switch (this) {
    football => l10n.sportFootball,
    padel => l10n.sportPadel,
    tennis => l10n.sportTennis,
    basketball => l10n.sportBasketball,
    volleyball => l10n.sportVolleyball,
    other => l10n.sportOther,
  };

  static SportType fromApi(Object? value) =>
      SportType.values.firstWhere((s) => s.apiName == value.toString(), orElse: () => SportType.other);
}

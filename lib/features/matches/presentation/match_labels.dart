import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/match_models.dart';

extension MatchStatusLabels on MatchStatus {
  String label(AppLocalizations l10n) => switch (this) {
    MatchStatus.open => l10n.matchStatusOpen,
    MatchStatus.full => l10n.matchStatusFull,
    MatchStatus.inProgress => l10n.matchStatusInProgress,
    MatchStatus.completed => l10n.matchStatusCompleted,
    MatchStatus.cancelled => l10n.matchStatusCancelled,
  };

  Color get color => switch (this) {
    MatchStatus.open => AppColors.primary,
    MatchStatus.full || MatchStatus.inProgress => AppColors.primaryMid,
    MatchStatus.completed => AppColors.black600,
    MatchStatus.cancelled => AppColors.error,
  };
}

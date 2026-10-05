import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/recurring_models.dart';

extension RecurringStatusLabels on RecurringStatus {
  String label(AppLocalizations l10n) => switch (this) {
    RecurringStatus.pending => l10n.recurringStatusPending,
    RecurringStatus.confirmed => l10n.recurringStatusConfirmed,
    RecurringStatus.rejected => l10n.recurringStatusRejected,
    RecurringStatus.cancelled => l10n.recurringStatusCancelled,
    RecurringStatus.expired => l10n.recurringStatusExpired,
  };

  Color get color => switch (this) {
    RecurringStatus.confirmed => AppColors.primary,
    RecurringStatus.pending => AppColors.primaryMid,
    RecurringStatus.rejected || RecurringStatus.cancelled => AppColors.error,
    RecurringStatus.expired => AppColors.black600,
  };
}

String weekdayName(AppLocalizations l10n, int day) => switch (day) {
  0 => l10n.weekdaySun,
  1 => l10n.weekdayMon,
  2 => l10n.weekdayTue,
  3 => l10n.weekdayWed,
  4 => l10n.weekdayThu,
  5 => l10n.weekdayFri,
  _ => l10n.weekdaySat,
};

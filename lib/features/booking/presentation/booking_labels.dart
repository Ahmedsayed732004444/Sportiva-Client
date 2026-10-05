import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/booking_models.dart';

extension BookingStatusLabels on BookingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    BookingStatus.pending => l10n.statusPending,
    BookingStatus.confirmed => l10n.statusConfirmed,
    BookingStatus.rejected => l10n.statusRejected,
    BookingStatus.cancelled => l10n.statusCancelled,
    BookingStatus.completed => l10n.statusCompleted,
    BookingStatus.noShow => l10n.statusNoShow,
    BookingStatus.expired => l10n.statusExpired,
  };

  Color get color => switch (this) {
    BookingStatus.confirmed || BookingStatus.completed => AppColors.primary,
    BookingStatus.pending => AppColors.primaryMid,
    BookingStatus.rejected || BookingStatus.cancelled || BookingStatus.noShow => AppColors.error,
    BookingStatus.expired => AppColors.black600,
  };
}

extension CourtPartLabels on CourtPart {
  String label(AppLocalizations l10n) => switch (this) {
    CourtPart.full => l10n.fullCourt,
    CourtPart.halfA => l10n.halfA,
    CourtPart.halfB => l10n.halfB,
  };
}

extension PlayFormatLabels on PlayFormat {
  String label(AppLocalizations l10n) => switch (this) {
    PlayFormat.singles => l10n.singles,
    PlayFormat.doubles => l10n.doubles,
  };
}

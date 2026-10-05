import 'package:flutter/material.dart';

import '../../../core/localization/price_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/tournament_models.dart';

extension TournamentStatusLabels on TournamentStatus {
  String label(AppLocalizations l10n) => switch (this) {
    TournamentStatus.draft => l10n.tournamentDraft,
    TournamentStatus.registrationOpen => l10n.tournamentRegistrationOpen,
    TournamentStatus.registrationClosed => l10n.tournamentRegistrationClosed,
    TournamentStatus.inProgress => l10n.tournamentInProgress,
    TournamentStatus.completed => l10n.tournamentCompleted,
    TournamentStatus.cancelled => l10n.tournamentCancelled,
  };

  Color get color => switch (this) {
    TournamentStatus.registrationOpen => AppColors.primary,
    TournamentStatus.inProgress => AppColors.primaryMid,
    TournamentStatus.cancelled => AppColors.error,
    _ => AppColors.black600,
  };
}

extension TournamentFormatLabels on TournamentFormat {
  String label(AppLocalizations l10n) => switch (this) {
    TournamentFormat.knockout => l10n.formatKnockout,
    TournamentFormat.league => l10n.formatLeague,
    TournamentFormat.groupsKnockout => l10n.formatGroupsKnockout,
  };
}

extension TeamStatusLabels on TeamStatus {
  String label(AppLocalizations l10n) => switch (this) {
    TeamStatus.forming => l10n.teamStatusForming,
    TeamStatus.pendingPayment => l10n.teamStatusPendingPayment,
    TeamStatus.pendingApproval => l10n.teamStatusPendingApproval,
    TeamStatus.approved => l10n.teamStatusApproved,
    TeamStatus.rejected => l10n.teamStatusRejected,
    TeamStatus.withdrawn => l10n.teamStatusWithdrawn,
    TeamStatus.cancelled => l10n.teamStatusCancelled,
  };

  Color get color => switch (this) {
    TeamStatus.approved => AppColors.primary,
    TeamStatus.rejected || TeamStatus.cancelled || TeamStatus.withdrawn => AppColors.error,
    _ => AppColors.primaryMid,
  };
}

extension MemberStatusLabels on MemberStatus {
  String label(AppLocalizations l10n) => switch (this) {
    MemberStatus.invited => l10n.memberInvited,
    MemberStatus.accepted => l10n.memberAccepted,
    MemberStatus.declined => l10n.memberDeclined,
    MemberStatus.removed => l10n.memberRemoved,
  };
}

String feeLabel(AppLocalizations l10n, int piasters) =>
    piasters == 0 ? l10n.free : l10n.feeAmount(formatPounds(piasters));

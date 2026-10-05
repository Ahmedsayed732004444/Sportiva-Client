import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';

extension ReportReasonLabels on ReportReason {
  String label(AppLocalizations l10n) => switch (this) {
    ReportReason.sexualContent => l10n.reasonSexualContent,
    ReportReason.violence => l10n.reasonViolence,
    ReportReason.harassment => l10n.reasonHarassment,
    ReportReason.spam => l10n.reasonSpam,
    ReportReason.misinformation => l10n.reasonMisinformation,
    ReportReason.impersonation => l10n.reasonImpersonation,
    ReportReason.other => l10n.reasonOther,
  };
}

// Asks for a reason and files the report. [targetType] is what the API calls it: Post, Comment, User.
Future<void> reportContent(
  BuildContext context,
  SocialRepository repository, {
  required String targetType,
  required String targetId,
}) async {
  final l10n = context.l10n;
  final reason = await showModalBottomSheet<ReportReason>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(l10n.reportTitle, style: Theme.of(context).textTheme.titleMedium)),
          for (final reason in ReportReason.values)
            ListTile(title: Text(reason.label(l10n)), onTap: () => Navigator.pop(context, reason)),
        ],
      ),
    ),
  );
  if (reason == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await repository.report(targetType: targetType, targetId: targetId, reason: reason);
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.messageFor(l10n) ?? l10n.unknownError)));
  }
}

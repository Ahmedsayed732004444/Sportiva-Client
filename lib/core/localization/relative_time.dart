import '../../l10n/app_localizations.dart';

// "now", "5m ago", "3h ago", "2d ago", then the date.
String relativeTime(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().toUtc().difference(time.toUtc());
  if (diff.inMinutes < 1) return l10n.timeNow;
  if (diff.inHours < 1) return l10n.timeMinutes(diff.inMinutes);
  if (diff.inDays < 1) return l10n.timeHours(diff.inHours);
  if (diff.inDays < 7) return l10n.timeDays(diff.inDays);

  final local = time.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

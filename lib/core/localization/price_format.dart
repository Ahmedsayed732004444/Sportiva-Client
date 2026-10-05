import '../../l10n/app_localizations.dart';

// 30000 piasters = "300": whole pounds without decimals, otherwise two.
String formatPounds(int piasters) {
  final pounds = piasters / 100;
  return pounds == pounds.roundToDouble() ? pounds.round().toString() : pounds.toStringAsFixed(2);
}

String formatPricePerHour(AppLocalizations l10n, int piasters) => l10n.perHour(formatPounds(piasters));

// "150" or "150.5" typed in a form -> piasters; null when it isn't a number.
int? parsePiasters(String text) {
  final pounds = double.tryParse(text.trim().replaceAll(',', '.'));
  return pounds == null || pounds < 0 ? null : (pounds * 100).round();
}

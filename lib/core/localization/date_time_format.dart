import 'package:intl/intl.dart';

// Dates and times in the language of the app. The API sends "HH:mm:ss" times and "yyyy-MM-dd" days (Cairo time).
String formatDay(String locale, DateTime day) => DateFormat('EEE d MMM', locale).format(day);

String formatLongDay(String locale, DateTime day) => DateFormat('EEEE d MMMM', locale).format(day);

String formatTime(String locale, String hms) {
  final parts = hms.split(':');
  final time = DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  return DateFormat.jm(locale).format(time);
}

String apiDay(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

DateTime parseApiDay(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

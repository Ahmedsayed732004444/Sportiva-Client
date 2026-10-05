import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/sport_type.dart';
import 'booking_models.dart';

enum RecurringStatus {
  pending,
  confirmed,
  rejected,
  cancelled,
  expired;

  static RecurringStatus fromApi(Object? value) => switch (value.toString()) {
    'Confirmed' => confirmed,
    'Rejected' => rejected,
    'Cancelled' => cancelled,
    'Expired' => expired,
    _ => pending,
  };
}

class RecurringWeek {
  const RecurringWeek({required this.day, required this.isAvailable, required this.pricePiasters});

  final String day;
  final bool isAvailable;
  final int pricePiasters;

  factory RecurringWeek.fromJson(Map<String, dynamic> json) => RecurringWeek(
    day: json['day'] as String,
    isAvailable: json['isAvailable'] as bool? ?? false,
    pricePiasters: (json['pricePiasters'] as num).toInt(),
  );
}

class RecurringPreview {
  const RecurringPreview({required this.weeks, required this.availableWeeks, required this.totalPiasters});

  final List<RecurringWeek> weeks;
  final int availableWeeks;
  final int totalPiasters;

  factory RecurringPreview.fromJson(Map<String, dynamic> json) => RecurringPreview(
    weeks: (json['weeks'] as List).cast<Map<String, dynamic>>().map(RecurringWeek.fromJson).toList(),
    availableWeeks: json['availableWeeks'] as int,
    totalPiasters: (json['totalPricePiasters'] as num).toInt(),
  );
}

class RecurringBooking {
  const RecurringBooking({
    required this.id,
    required this.status,
    required this.courtName,
    required this.sport,
    required this.club,
    required this.dayOfWeek,
    required this.startTime,
    required this.durationMinutes,
    required this.firstDay,
    required this.weeks,
    required this.canCancel,
    required this.canRespond,
    this.customerName,
    this.customerPhone,
    this.responseDeadlineUtc,
  });

  final String id;
  final RecurringStatus status;
  final String courtName;
  final SportType sport;
  final ClubRef club;
  // 0 = Sunday ... 6 = Saturday.
  final int dayOfWeek;
  final String startTime;
  final int durationMinutes;
  final String firstDay;
  final int weeks;
  final bool canCancel;
  final bool canRespond;
  final String? customerName;
  final String? customerPhone;
  final DateTime? responseDeadlineUtc;

  factory RecurringBooking.fromJson(Map<String, dynamic> json) {
    const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final day = json['dayOfWeek'];
    return RecurringBooking(
      id: json['id'] as String,
      status: RecurringStatus.fromApi(json['status']),
      courtName: json['courtName'] as String,
      sport: SportType.fromApi(json['sportType']),
      club: ClubRef.fromJson(json['club'] as Map<String, dynamic>),
      dayOfWeek: day is int ? day : names.indexOf(day.toString()).clamp(0, 6),
      startTime: json['startTime'] as String,
      durationMinutes: json['durationMinutes'] as int,
      firstDay: json['firstDay'] as String,
      weeks: json['weeks'] as int,
      canCancel: json['canCancel'] as bool? ?? false,
      canRespond: json['canRespond'] as bool? ?? false,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      responseDeadlineUtc: DateTime.tryParse(json['responseDeadlineUtc']?.toString() ?? ''),
    );
  }
}

// What the player (or the club, for a manual one) asks for.
class RecurringRequest {
  const RecurringRequest({
    required this.courtId,
    required this.firstDay,
    required this.startTime,
    required this.durationMinutes,
    required this.part,
    required this.weeks,
    required this.skipUnavailable,
    this.playFormat,
  });

  final String courtId;
  final String firstDay;
  final String startTime;
  final int durationMinutes;
  final CourtPart part;
  final int weeks;
  final bool skipUnavailable;
  final PlayFormat? playFormat;

  Map<String, dynamic> toJson() => {
    'courtId': courtId,
    'firstDay': firstDay,
    'startTime': startTime,
    'durationMinutes': durationMinutes,
    'courtPart': part.apiName,
    'playFormat': playFormat?.apiName,
    'weeks': weeks,
    'skipUnavailableWeeks': skipUnavailable,
  };
}

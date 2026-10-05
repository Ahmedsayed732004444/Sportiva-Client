import '../../booking/data/booking_models.dart';
import '../../catalog/data/sport_type.dart';

enum ConfirmationMode {
  manual('Manual'),
  automatic('Automatic');

  const ConfirmationMode(this.apiName);
  final String apiName;

  static ConfirmationMode fromApi(Object? value) => value.toString() == 'Automatic' ? automatic : manual;
}

class PriceRule {
  const PriceRule({
    required this.startTime,
    required this.endTime,
    required this.pricePiasters,
    this.dayOfWeek,
    this.halfCourtPiasters,
  });

  // 0 = Sunday ... 6 = Saturday (System.DayOfWeek); null = every day.
  final int? dayOfWeek;
  final String startTime;
  final String endTime;
  final int pricePiasters;
  final int? halfCourtPiasters;

  factory PriceRule.fromJson(Map<String, dynamic> json) => PriceRule(
    dayOfWeek: _dayIndex(json['dayOfWeek']),
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    pricePiasters: (json['pricePerHourPiasters'] as num).toInt(),
    halfCourtPiasters: (json['halfCourtPricePerHourPiasters'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'pricePerHourPiasters': pricePiasters,
    'halfCourtPricePerHourPiasters': halfCourtPiasters,
  };

  static int? _dayIndex(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final index = names.indexOf(value.toString());
    return index < 0 ? null : index;
  }
}

class GalleryImage {
  const GalleryImage({required this.id, required this.url, required this.isCover});

  final String id;
  final String url;
  final bool isCover;

  factory GalleryImage.fromJson(Map<String, dynamic> json) =>
      GalleryImage(id: json['id'] as String, url: json['url'] as String, isCover: json['isCover'] as bool? ?? false);
}

class OwnerCourt {
  const OwnerCourt({
    required this.id,
    required this.name,
    required this.sport,
    required this.isActive,
    required this.pricePiasters,
    required this.allowsHalfCourt,
    this.coverUrl,
    this.description,
    this.confirmationMode = ConfirmationMode.manual,
    this.responseTimeoutMinutes,
    this.halfCourtPiasters,
    this.maxPlayers,
    this.defaultDurationMinutes,
    this.allowedDurations = const [],
    this.priceRules = const [],
    this.images = const [],
  });

  final String id;
  final String name;
  final SportType sport;
  final bool isActive;
  final int pricePiasters;
  final bool allowsHalfCourt;
  final String? coverUrl;
  final String? description;
  final ConfirmationMode confirmationMode;
  final int? responseTimeoutMinutes;
  final int? halfCourtPiasters;
  final int? maxPlayers;
  final int? defaultDurationMinutes;
  final List<int> allowedDurations;
  final List<PriceRule> priceRules;
  final List<GalleryImage> images;

  bool get hasPlayFormat => PlayFormat.appliesTo(sport);

  factory OwnerCourt.fromJson(Map<String, dynamic> json) => OwnerCourt(
    id: json['id'] as String,
    name: json['name'] as String,
    sport: SportType.fromApi(json['sportType']),
    isActive: json['isActive'] as bool? ?? true,
    pricePiasters: (json['pricePerHourPiasters'] as num).toInt(),
    allowsHalfCourt: json['allowsHalfCourt'] as bool? ?? false,
    coverUrl: json['coverImageUrl'] as String?,
    description: json['description'] as String?,
    confirmationMode: ConfirmationMode.fromApi(json['confirmationMode']),
    responseTimeoutMinutes: json['responseTimeoutMinutes'] as int?,
    halfCourtPiasters: (json['halfCourtPricePerHourPiasters'] as num?)?.toInt(),
    maxPlayers: json['maxPlayers'] as int?,
    defaultDurationMinutes: json['defaultDurationMinutes'] as int?,
    allowedDurations: (json['allowedDurations'] as List? ?? const []).cast<int>(),
    priceRules: (json['priceRules'] as List? ?? const []).cast<Map<String, dynamic>>().map(PriceRule.fromJson).toList(),
    images: (json['images'] as List? ?? const []).cast<Map<String, dynamic>>().map(GalleryImage.fromJson).toList(),
  );
}

// One 30-minute unit of a court's day, as the club sees it (it can be closed for bookings).
class ManagedSlot {
  const ManagedSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isClosed,
    required this.bookedBy,
  });

  final String id;
  final String startTime;
  final String endTime;
  final bool isClosed;
  final List<String> bookedBy;

  bool get isBooked => bookedBy.isNotEmpty;

  factory ManagedSlot.fromJson(Map<String, dynamic> json) => ManagedSlot(
    id: json['slotId'] as String,
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    isClosed: json['isClosed'] as bool? ?? false,
    bookedBy: (json['bookings'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((b) => (b['customerName'] as String?) ?? '#${b['number']}')
        .toList(),
  );
}

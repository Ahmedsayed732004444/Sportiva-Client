import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/sport_type.dart';

enum CourtPart {
  full('Full'),
  halfA('HalfA'),
  halfB('HalfB');

  const CourtPart(this.apiName);
  final String apiName;

  static CourtPart fromApi(Object? value) =>
      CourtPart.values.firstWhere((p) => p.apiName == value.toString(), orElse: () => CourtPart.full);
}

enum PlayFormat {
  singles('Singles'),
  doubles('Doubles');

  const PlayFormat(this.apiName);
  final String apiName;

  // Only these sports have a play format.
  static bool appliesTo(SportType sport) => sport == SportType.padel || sport == SportType.tennis;
}

enum SlotStatus { available, partiallyBooked, booked, closed, past }

// One 30-minute unit of a court's day.
class SlotUnit {
  const SlotUnit({
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.freeParts,
    required this.pricePerHourPiasters,
    this.halfCourtPricePerHourPiasters,
  });

  final String startTime;
  final String endTime;
  final SlotStatus status;
  final Set<CourtPart> freeParts;
  final int pricePerHourPiasters;
  final int? halfCourtPricePerHourPiasters;

  factory SlotUnit.fromJson(Map<String, dynamic> json) => SlotUnit(
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    status: switch (json['status'].toString()) {
      'Available' => SlotStatus.available,
      'PartiallyBooked' => SlotStatus.partiallyBooked,
      'Booked' => SlotStatus.booked,
      'Closed' => SlotStatus.closed,
      _ => SlotStatus.past,
    },
    freeParts: (json['freeParts'] as List).map(CourtPart.fromApi).toSet(),
    pricePerHourPiasters: (json['pricePerHourPiasters'] as num).toInt(),
    halfCourtPricePerHourPiasters: (json['halfCourtPricePerHourPiasters'] as num?)?.toInt(),
  );
}

enum BookingStatus {
  pending,
  confirmed,
  rejected,
  cancelled,
  completed,
  noShow,
  expired;

  static BookingStatus fromApi(Object? value) => switch (value.toString()) {
    'Pending' => pending,
    'Confirmed' => confirmed,
    'Rejected' => rejected,
    'Cancelled' => cancelled,
    'Completed' => completed,
    'NoShow' => noShow,
    _ => expired,
  };
}

class Booking {
  const Booking({
    required this.id,
    required this.code,
    required this.status,
    required this.courtName,
    required this.sport,
    required this.club,
    required this.clubPhone,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.pricePiasters,
    required this.canCancel,
    this.canOpenMatch = false,
    this.canReview = false,
    this.canRespond = false,
    this.canComplete = false,
    this.canMarkNoShow = false,
    this.canRatePlayer = false,
    this.isMine = true,
    this.matchId,
    this.customerUserId,
    this.customerName,
    this.customerPhone,
    this.customerRating,
    this.customerReviewsCount = 0,
    this.rejectionReason,
    this.cancellationReason,
    this.responseDeadlineUtc,
  });

  final String id;
  final String code;
  final BookingStatus status;
  final String courtName;
  final SportType sport;
  final ClubRef club;
  final String clubPhone;
  // "yyyy-MM-dd" and "HH:mm:ss", Cairo time.
  final String day;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final int pricePiasters;
  final bool canCancel;
  final bool canOpenMatch;
  // The player can rate the court / the club can rate the player.
  final bool canReview;
  final bool canRatePlayer;
  // What the club can do with it.
  final bool canRespond;
  final bool canComplete;
  final bool canMarkNoShow;
  final bool isMine;
  final String? matchId;
  final String? customerUserId;
  final String? customerName;
  final String? customerPhone;
  final double? customerRating;
  final int customerReviewsCount;
  final String? rejectionReason;
  final String? cancellationReason;
  final DateTime? responseDeadlineUtc;

  bool get isActive => status == BookingStatus.pending || status == BookingStatus.confirmed;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    code: json['code'] as String,
    status: BookingStatus.fromApi(json['status']),
    courtName: json['courtName'] as String,
    sport: SportType.fromApi(json['sportType']),
    club: ClubRef.fromJson(json['club'] as Map<String, dynamic>),
    clubPhone: json['clubPhone'] as String? ?? '',
    day: json['day'] as String,
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    durationMinutes: json['durationMinutes'] as int,
    pricePiasters: (json['pricePiasters'] as num).toInt(),
    canCancel: json['canCancel'] as bool? ?? false,
    canOpenMatch: json['canOpenMatch'] as bool? ?? false,
    canReview: json['canReview'] as bool? ?? false,
    canRespond: json['canRespond'] as bool? ?? false,
    canComplete: json['canComplete'] as bool? ?? false,
    canMarkNoShow: json['canMarkNoShow'] as bool? ?? false,
    canRatePlayer: json['canRatePlayer'] as bool? ?? false,
    isMine: json['isMine'] as bool? ?? true,
    matchId: json['matchId'] as String?,
    customerUserId: json['customerUserId'] as String?,
    customerName: json['customerName'] as String?,
    customerPhone: json['customerPhone'] as String?,
    customerRating: (json['customerRating'] as num?)?.toDouble(),
    customerReviewsCount: json['customerReviewsCount'] as int? ?? 0,
    rejectionReason: json['rejectionReason'] as String?,
    cancellationReason: json['cancellationReason'] as String?,
    responseDeadlineUtc: DateTime.tryParse(json['responseDeadlineUtc']?.toString() ?? ''),
  );

  Booking copyWith({BookingStatus? status, bool? canCancel}) => Booking(
    id: id,
    code: code,
    status: status ?? this.status,
    courtName: courtName,
    sport: sport,
    club: club,
    clubPhone: clubPhone,
    day: day,
    startTime: startTime,
    endTime: endTime,
    durationMinutes: durationMinutes,
    pricePiasters: pricePiasters,
    canCancel: canCancel ?? this.canCancel,
    canOpenMatch: canOpenMatch,
    canReview: canReview,
    canRespond: canRespond,
    canComplete: canComplete,
    canMarkNoShow: canMarkNoShow,
    canRatePlayer: canRatePlayer,
    isMine: isMine,
    matchId: matchId,
    customerUserId: customerUserId,
    customerName: customerName,
    customerPhone: customerPhone,
    customerRating: customerRating,
    customerReviewsCount: customerReviewsCount,
    rejectionReason: rejectionReason,
    cancellationReason: cancellationReason,
    responseDeadlineUtc: responseDeadlineUtc,
  );
}

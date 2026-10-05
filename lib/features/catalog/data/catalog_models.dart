import 'sport_type.dart';

// The club a court belongs to (ClubSummary in the API).
class ClubRef {
  const ClubRef({required this.id, required this.name, this.logoUrl, this.governorateName, this.city});

  final String id;
  final String name;
  final String? logoUrl;
  final String? governorateName;
  final String? city;

  factory ClubRef.fromJson(Map<String, dynamic> json) => ClubRef(
    id: json['id'] as String,
    name: json['name'] as String,
    logoUrl: json['logoUrl'] as String?,
    governorateName: json['governorateName'] as String?,
    city: json['city'] as String?,
  );
}

class CourtListItem {
  const CourtListItem({
    required this.id,
    required this.name,
    required this.sport,
    required this.pricePerHourPiasters,
    required this.club,
    this.coverImageUrl,
    this.distanceText,
    this.averageRating,
    this.reviewsCount = 0,
  });

  final String id;
  final String name;
  final SportType sport;
  final int pricePerHourPiasters;
  final ClubRef club;
  final String? coverImageUrl;
  final String? distanceText;
  final double? averageRating;
  final int reviewsCount;

  // A court shows its club's picture (courts of one club share it); its own cover is only the fallback.
  String? get imageUrl => club.logoUrl ?? coverImageUrl;

  factory CourtListItem.fromJson(Map<String, dynamic> json) => CourtListItem(
    id: json['id'] as String,
    name: json['name'] as String,
    sport: SportType.fromApi(json['sportType']),
    pricePerHourPiasters: (json['pricePerHourPiasters'] as num).toInt(),
    club: ClubRef.fromJson(json['club'] as Map<String, dynamic>),
    coverImageUrl: json['coverImageUrl'] as String?,
    distanceText: json['distanceText'] as String?,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
  );
}

class ClubListItem {
  const ClubListItem({
    required this.id,
    required this.name,
    required this.sports,
    required this.courtsCount,
    this.logoUrl,
    this.coverUrl,
    this.city,
    this.governorateName,
    this.distanceText,
    this.averageRating,
    this.reviewsCount = 0,
  });

  final String id;
  final String name;
  final List<SportType> sports;
  final int courtsCount;
  final String? logoUrl;
  final String? coverUrl;
  final String? city;
  final String? governorateName;
  final String? distanceText;
  final double? averageRating;
  final int reviewsCount;

  String? get imageUrl => coverUrl ?? logoUrl;

  factory ClubListItem.fromJson(Map<String, dynamic> json) => ClubListItem(
    id: json['id'] as String,
    name: json['name'] as String,
    sports: (json['sports'] as List? ?? const []).map(SportType.fromApi).toList(),
    courtsCount: json['courtsCount'] as int? ?? 0,
    logoUrl: json['logoUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    city: json['city'] as String?,
    governorateName: json['governorateName'] as String?,
    distanceText: json['distanceText'] as String?,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
  );
}

class ImageItem {
  const ImageItem({required this.url, required this.isCover});

  final String url;
  final bool isCover;

  factory ImageItem.fromJson(Map<String, dynamic> json) =>
      ImageItem(url: json['url'] as String, isCover: json['isCover'] as bool? ?? false);
}

class WorkingDay {
  const WorkingDay({required this.dayOfWeek, required this.isClosed, required this.opensAt, required this.closesAt});

  // "Sunday" ... "Saturday", as the API names them.
  final String dayOfWeek;
  final bool isClosed;
  final String opensAt;
  final String closesAt;

  factory WorkingDay.fromJson(Map<String, dynamic> json) => WorkingDay(
    dayOfWeek: json['dayOfWeek'].toString(),
    isClosed: json['isClosed'] as bool? ?? false,
    opensAt: json['opensAt'] as String,
    closesAt: json['closesAt'] as String,
  );
}

class ClubDetails {
  const ClubDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.workingHours,
    required this.sports,
    required this.courtsCount,
    this.logoUrl,
    this.coverUrl,
    this.images = const [],
    this.city,
    this.governorateName,
    this.mapUrl,
    this.latitude,
    this.longitude,
    this.averageRating,
    this.reviewsCount = 0,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final List<WorkingDay> workingHours;
  final List<SportType> sports;
  final int courtsCount;
  final String? logoUrl;
  final String? coverUrl;
  final List<ImageItem> images;
  final String? city;
  final String? governorateName;
  final String? mapUrl;
  final double? latitude;
  final double? longitude;
  final double? averageRating;
  final int reviewsCount;

  String? get imageUrl => coverUrl ?? logoUrl;

  factory ClubDetails.fromJson(Map<String, dynamic> json) => ClubDetails(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    workingHours: (json['workingHours'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(WorkingDay.fromJson)
        .toList(),
    sports: (json['sports'] as List? ?? const []).map(SportType.fromApi).toList(),
    courtsCount: json['courtsCount'] as int? ?? 0,
    logoUrl: json['logoUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    images: (json['images'] as List? ?? const []).cast<Map<String, dynamic>>().map(ImageItem.fromJson).toList(),
    city: json['city'] as String?,
    governorateName: json['governorateName'] as String?,
    mapUrl: json['mapUrl'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
  );
}

class CourtDetails {
  const CourtDetails({
    required this.id,
    required this.name,
    required this.sport,
    required this.club,
    required this.pricePerHourPiasters,
    required this.allowsHalfCourt,
    required this.allowedDurations,
    required this.defaultDurationMinutes,
    required this.maxPlayers,
    required this.isAutomatic,
    required this.canBook,
    this.description,
    this.halfCourtPricePerHourPiasters,
    this.coverImageUrl,
    this.averageRating,
    this.reviewsCount = 0,
  });

  final String id;
  final String name;
  final SportType sport;
  final ClubRef club;
  final int pricePerHourPiasters;
  final bool allowsHalfCourt;
  final List<int> allowedDurations;
  final int defaultDurationMinutes;
  final int maxPlayers;
  // Automatic: the booking is confirmed at once; otherwise the club confirms it.
  final bool isAutomatic;
  final bool canBook;
  final String? description;
  final int? halfCourtPricePerHourPiasters;
  final String? coverImageUrl;
  final double? averageRating;
  final int reviewsCount;

  String? get imageUrl => club.logoUrl ?? coverImageUrl;

  factory CourtDetails.fromJson(Map<String, dynamic> json) => CourtDetails(
    id: json['id'] as String,
    name: json['name'] as String,
    sport: SportType.fromApi(json['sportType']),
    club: ClubRef.fromJson(json['club'] as Map<String, dynamic>),
    pricePerHourPiasters: (json['pricePerHourPiasters'] as num).toInt(),
    allowsHalfCourt: json['allowsHalfCourt'] as bool? ?? false,
    allowedDurations: (json['allowedDurations'] as List).cast<int>(),
    defaultDurationMinutes: json['defaultDurationMinutes'] as int? ?? 60,
    maxPlayers: json['maxPlayers'] as int? ?? 0,
    isAutomatic: json['confirmationMode'].toString() == 'Automatic',
    canBook: json['canBook'] as bool? ?? true,
    description: json['description'] as String?,
    halfCourtPricePerHourPiasters: (json['halfCourtPricePerHourPiasters'] as num?)?.toInt(),
    coverImageUrl: json['coverImageUrl'] as String?,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
  );
}

class ReviewItem {
  const ReviewItem({required this.rating, required this.reviewerName, required this.createdAt, this.comment});

  final int rating;
  final String reviewerName;
  final DateTime createdAt;
  final String? comment;

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
    rating: json['rating'] as int,
    comment: json['comment'] as String?,
    reviewerName: ((json['reviewer'] as Map<String, dynamic>?)?['fullName'] as String?) ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

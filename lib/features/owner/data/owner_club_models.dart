import '../../catalog/data/catalog_models.dart';
import 'owner_court_models.dart';

enum SubscriptionState {
  none,
  active,
  gracePeriod,
  expired;

  static SubscriptionState fromApi(Object? value) => switch (value.toString()) {
    'Active' => active,
    'GracePeriod' => gracePeriod,
    'Expired' => expired,
    _ => none,
  };
}

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.state,
    required this.courtsCount,
    required this.renewalRequired,
    required this.canAddCourts,
    this.endsAt,
    this.planName,
    this.maxCourts,
  });

  final SubscriptionState state;
  final int courtsCount;
  final bool renewalRequired;
  final bool canAddCourts;
  final DateTime? endsAt;
  final String? planName;
  final int? maxCourts;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) => SubscriptionStatus(
    state: SubscriptionState.fromApi(json['state']),
    courtsCount: json['courtsCount'] as int? ?? 0,
    renewalRequired: json['renewalRequired'] as bool? ?? false,
    canAddCourts: json['canAddCourts'] as bool? ?? false,
    endsAt: DateTime.tryParse(json['endsAt']?.toString() ?? ''),
    planName: json['planName'] as String?,
    maxCourts: json['maxCourts'] as int?,
  );
}

class OwnerClub {
  const OwnerClub({
    required this.id,
    required this.name,
    required this.governorateId,
    required this.city,
    required this.address,
    required this.phone,
    required this.isActive,
    required this.isOwner,
    required this.workingHours,
    this.images = const [],
    this.logoUrl,
    this.coverUrl,
    this.mapUrl,
    this.email,
    this.rating,
    this.reviewsCount = 0,
    this.subscription,
  });

  final String id;
  final String name;
  final int governorateId;
  final String city;
  final String address;
  final String phone;
  final bool isActive;
  final bool isOwner;
  final List<WorkingDay> workingHours;
  final List<GalleryImage> images;
  final String? logoUrl;
  final String? coverUrl;
  final String? mapUrl;
  final String? email;
  final double? rating;
  final int reviewsCount;
  final SubscriptionStatus? subscription;

  factory OwnerClub.fromJson(Map<String, dynamic> json) => OwnerClub(
    id: json['id'] as String,
    name: json['name'] as String,
    governorateId: json['governorateId'] as int,
    city: json['city'] as String? ?? '',
    address: json['address'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    isOwner: json['isOwner'] as bool? ?? false,
    workingHours: (json['workingHours'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(WorkingDay.fromJson)
        .toList(),
    images: (json['images'] as List? ?? const []).cast<Map<String, dynamic>>().map(GalleryImage.fromJson).toList(),
    logoUrl: json['logoUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    mapUrl: json['mapUrl'] as String?,
    email: json['email'] as String?,
    rating: (json['averageRating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
    subscription: json['subscription'] == null
        ? null
        : SubscriptionStatus.fromJson(json['subscription'] as Map<String, dynamic>),
  );
}

class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.pricePiasters,
    required this.maxCourts,
    required this.durationDays,
  });

  final String id;
  final String name;
  final int pricePiasters;
  final int maxCourts;
  final int durationDays;

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    pricePiasters: (json['pricePiasters'] as num).toInt(),
    maxCourts: json['maxCourts'] as int,
    durationDays: json['durationDays'] as int,
  );
}

enum StaffPermission {
  manageBookings('ManageBookings'),
  manualBookings('ManualBookings'),
  viewReports('ViewReports'),
  checkIn('CheckIn'),
  manageSlots('ManageSlots'),
  ratePlayers('RatePlayers'),
  tournamentResults('TournamentResults'),
  editCourts('EditCourts'),
  manageTournaments('ManageTournaments');

  const StaffPermission(this.apiName);
  final String apiName;

  static StaffPermission? fromApi(Object? value) =>
      StaffPermission.values.where((p) => p.apiName == value.toString()).firstOrNull;
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.permissions,
    this.phone,
  });

  final String id;
  final String fullName;
  final String email;
  final bool isActive;
  final List<StaffPermission> permissions;
  final String? phone;

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
    id: json['id'] as String,
    fullName: '${json['firstName']} ${json['lastName']}'.trim(),
    email: json['email'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    permissions: (json['permissions'] as List? ?? const [])
        .map(StaffPermission.fromApi)
        .whereType<StaffPermission>()
        .toList(),
    phone: json['phoneNumber'] as String?,
  );
}

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.details,
  });

  final int id;
  final String userName;
  final String action;
  final String entityType;
  final DateTime createdAt;
  final String? details;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
    id: (json['id'] as num).toInt(),
    userName: (json['user'] as Map<String, dynamic>?)?['fullName'] as String? ?? '',
    action: json['action'] as String? ?? '',
    entityType: json['entityType'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
    details: json['details'] as String?,
  );
}

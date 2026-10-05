import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/sport_type.dart';

enum MatchStatus {
  open,
  full,
  inProgress,
  completed,
  cancelled;

  static MatchStatus fromApi(Object? value) => switch (value.toString()) {
    'Open' => open,
    'Full' => full,
    'InProgress' => inProgress,
    'Completed' => completed,
    _ => cancelled,
  };
}

enum JoinRequestStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  static JoinRequestStatus? fromApi(Object? value) => switch (value?.toString()) {
    'Pending' => pending,
    'Accepted' => accepted,
    'Rejected' => rejected,
    'Withdrawn' => withdrawn,
    _ => null,
  };
}

class MatchPlayer {
  const MatchPlayer({required this.userId, required this.fullName, this.rating, this.reviewsCount = 0, this.avatarUrl});

  final String userId;
  final String fullName;
  final double? rating;
  final int reviewsCount;
  final String? avatarUrl;

  factory MatchPlayer.fromJson(Map<String, dynamic> json) => MatchPlayer(
    userId: json['userId'] as String,
    fullName: json['fullName'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
    avatarUrl: json['avatarUrl'] as String?,
  );
}

class FriendlyMatch {
  const FriendlyMatch({
    required this.id,
    required this.sport,
    required this.status,
    required this.organizer,
    required this.isExternal,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.playersNeeded,
    required this.acceptedPlayers,
    required this.players,
    required this.isOrganizer,
    required this.canJoin,
    required this.canCancel,
    required this.canLeave,
    this.canReview = false,
    this.club,
    this.courtName,
    this.bookingStatusName,
    this.placeName,
    this.address,
    this.city,
    this.note,
    this.myRequestStatus,
  });

  final String id;
  final SportType sport;
  final MatchStatus status;
  final MatchPlayer organizer;
  final bool isExternal;
  // "yyyy-MM-dd" / "HH:mm:ss" (Cairo time).
  final String day;
  final String startTime;
  final String endTime;
  final int playersNeeded;
  final int acceptedPlayers;
  final List<MatchPlayer> players;
  final bool isOrganizer;
  final bool canJoin;
  final bool canCancel;
  final bool canLeave;
  final bool canReview;
  final ClubRef? club;
  final String? courtName;
  final String? bookingStatusName;
  final String? placeName;
  final String? address;
  final String? city;
  final String? note;
  final JoinRequestStatus? myRequestStatus;

  int get spotsLeft => playersNeeded - acceptedPlayers;

  // Who is in, the organizer first: what the card shows as faces.
  List<MatchPlayer> get participants => [organizer, ...players.where((p) => p.userId != organizer.userId)];

  // Where it is played: the club and court, or the outside place.
  String get title => isExternal ? (placeName ?? '') : [club?.name, courtName].whereType<String>().join(' - ');

  bool get isMember => isOrganizer || myRequestStatus == JoinRequestStatus.accepted;

  // The booking behind a court match is still waiting for the club.
  bool get waitingForClub => !isExternal && bookingStatusName == 'Pending';

  factory FriendlyMatch.fromJson(Map<String, dynamic> json) => FriendlyMatch(
    id: json['id'] as String,
    sport: SportType.fromApi(json['sportType']),
    status: MatchStatus.fromApi(json['status']),
    organizer: MatchPlayer.fromJson(json['organizer'] as Map<String, dynamic>),
    isExternal: json['isExternal'] as bool? ?? false,
    day: json['day'] as String,
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    playersNeeded: json['playersNeeded'] as int,
    acceptedPlayers: json['acceptedPlayers'] as int,
    players: (json['players'] as List? ?? const []).cast<Map<String, dynamic>>().map(MatchPlayer.fromJson).toList(),
    isOrganizer: json['isOrganizer'] as bool? ?? false,
    canJoin: json['canJoin'] as bool? ?? false,
    canCancel: json['canCancel'] as bool? ?? false,
    canLeave: json['canLeave'] as bool? ?? false,
    canReview: json['canReview'] as bool? ?? false,
    club: json['club'] == null ? null : ClubRef.fromJson(json['club'] as Map<String, dynamic>),
    courtName: json['courtName'] as String?,
    bookingStatusName: json['bookingStatus']?.toString(),
    placeName: json['placeName'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    note: json['note'] as String?,
    myRequestStatus: JoinRequestStatus.fromApi(json['myRequestStatus']),
  );
}

class JoinRequest {
  const JoinRequest({required this.id, required this.player, required this.status});

  final String id;
  final MatchPlayer player;
  final JoinRequestStatus status;

  factory JoinRequest.fromJson(Map<String, dynamic> json) => JoinRequest(
    id: json['id'] as String,
    player: MatchPlayer.fromJson(json['player'] as Map<String, dynamic>),
    status: JoinRequestStatus.fromApi(json['status']) ?? JoinRequestStatus.pending,
  );
}

class Governorate {
  const Governorate({required this.id, required this.nameAr, required this.nameEn});

  final int id;
  final String nameAr;
  final String nameEn;

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  factory Governorate.fromJson(Map<String, dynamic> json) =>
      Governorate(id: json['id'] as int, nameAr: json['nameAr'] as String, nameEn: json['nameEn'] as String);
}

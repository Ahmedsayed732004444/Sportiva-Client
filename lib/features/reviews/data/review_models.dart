class MyReview {
  const MyReview({
    required this.id,
    required this.rating,
    required this.reviewerName,
    required this.createdAt,
    required this.isRevealed,
    required this.canEdit,
    this.comment,
    this.playerName,
    this.clubName,
    this.courtName,
  });

  final String id;
  final int rating;
  final String reviewerName;
  final DateTime createdAt;
  final bool isRevealed;
  final bool canEdit;
  final String? comment;
  final String? playerName;
  final String? clubName;
  final String? courtName;

  // What the rating is about: the court, the club, or the player.
  String get subject => playerName ?? [clubName, courtName].whereType<String>().join(' - ');

  factory MyReview.fromJson(Map<String, dynamic> json) => MyReview(
    id: json['id'] as String,
    rating: json['rating'] as int,
    reviewerName: (json['reviewer'] as Map<String, dynamic>?)?['fullName'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
    isRevealed: json['isRevealed'] as bool? ?? true,
    canEdit: json['canEdit'] as bool? ?? false,
    comment: json['comment'] as String?,
    playerName: (json['player'] as Map<String, dynamic>?)?['fullName'] as String?,
    clubName: json['clubName'] as String?,
    courtName: json['courtName'] as String?,
  );
}

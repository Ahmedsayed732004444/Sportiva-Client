enum MembershipStatus {
  pending,
  approved,
  rejected;

  static MembershipStatus fromApi(Object? value) => switch (value.toString()) {
    'Approved' => approved,
    'Rejected' => rejected,
    _ => pending,
  };
}

class MembershipMedia {
  const MembershipMedia({
    required this.id,
    required this.isVideo,
    required this.isReady,
    required this.isFailed,
    this.url,
    this.thumbnailUrl,
    this.fileName,
  });

  final String id;
  final bool isVideo;
  final bool isReady;
  final bool isFailed;
  final String? url;
  final String? thumbnailUrl;
  final String? fileName;

  factory MembershipMedia.fromJson(Map<String, dynamic> json) => MembershipMedia(
    id: json['id'] as String,
    isVideo: json['type'].toString() == 'Video',
    isReady: json['status'].toString() == 'Ready',
    isFailed: json['status'].toString() == 'Failed',
    url: json['url'] as String?,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    fileName: json['originalFileName'] as String?,
  );
}

class MembershipRequest {
  const MembershipRequest({
    required this.id,
    required this.status,
    required this.clubName,
    required this.governorateName,
    required this.city,
    required this.address,
    required this.phone,
    required this.media,
    this.note,
    this.rejectionReason,
  });

  final String id;
  final MembershipStatus status;
  final String clubName;
  final String governorateName;
  final String city;
  final String address;
  final String phone;
  final List<MembershipMedia> media;
  final String? note;
  final String? rejectionReason;

  bool get hasProcessingMedia => media.any((m) => !m.isReady && !m.isFailed);

  factory MembershipRequest.fromJson(Map<String, dynamic> json) => MembershipRequest(
    id: json['id'] as String,
    status: MembershipStatus.fromApi(json['status']),
    clubName: json['clubName'] as String? ?? '',
    governorateName: json['governorateName'] as String? ?? '',
    city: json['city'] as String? ?? '',
    address: json['address'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    media: (json['media'] as List? ?? const []).cast<Map<String, dynamic>>().map(MembershipMedia.fromJson).toList(),
    note: json['note'] as String?,
    rejectionReason: json['rejectionReason'] as String?,
  );
}

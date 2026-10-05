class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.entityType,
    this.entityId,
    this.actorName,
  });

  final String id;
  // The NotificationType name, e.g. "BookingConfirmed".
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? entityType;
  final String? entityId;
  final String? actorName;

  // Used for the list and for the realtime push (which has no isRead / createdAt).
  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['notificationId'] as String,
    type: json['type'].toString(),
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    isRead: json['isRead'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
    entityType: json['entityType'] as String?,
    entityId: json['entityId'] as String?,
    actorName: (json['actor'] as Map<String, dynamic>?)?['fullName'] as String?,
  );

  AppNotification asRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    isRead: true,
    createdAt: createdAt,
    entityType: entityType,
    entityId: entityId,
    actorName: actorName,
  );
}

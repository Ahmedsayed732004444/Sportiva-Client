// Who a chat is with: a match's group, or one person.
class ChatTarget {
  const ChatTarget.match(this.id) : isMatch = true;
  const ChatTarget.person(this.id) : isMatch = false;

  final String id;
  final bool isMatch;

  @override
  bool operator ==(Object other) => other is ChatTarget && other.id == id && other.isMatch == isMatch;

  @override
  int get hashCode => Object.hash(id, isMatch);
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.receiverId,
    this.matchId,
    this.deliveredAt,
    this.readAt,
    this.audioUrl,
    this.audioSeconds,
  });

  final int id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isMine;
  final String? receiverId;
  final String? matchId;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  // A voice note: the audio file and its length (the text is empty).
  final String? audioUrl;
  final int? audioSeconds;

  bool get isVoice => audioUrl != null;

  ChatMessage copyWith({DateTime? deliveredAt, DateTime? readAt}) => ChatMessage(
    id: id,
    senderId: senderId,
    senderName: senderName,
    text: text,
    sentAt: sentAt,
    isMine: isMine,
    receiverId: receiverId,
    matchId: matchId,
    deliveredAt: deliveredAt ?? this.deliveredAt,
    readAt: readAt ?? this.readAt,
    audioUrl: audioUrl,
    audioSeconds: audioSeconds,
  );

  // Does a message (pushed live) belong to this chat?
  bool belongsTo(ChatTarget target) =>
      target.isMatch ? matchId == target.id : matchId == null && (senderId == target.id || receiverId == target.id);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return ChatMessage(
      id: (json['id'] as num).toInt(),
      senderId: sender?['userId'] as String? ?? '',
      senderName: sender?['fullName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      isMine: json['isMine'] as bool? ?? false,
      receiverId: json['receiverId'] as String?,
      matchId: json['matchId'] as String?,
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
      audioUrl: json['audioUrl'] as String?,
      audioSeconds: (json['audioSeconds'] as num?)?.toInt(),
    );
  }
}

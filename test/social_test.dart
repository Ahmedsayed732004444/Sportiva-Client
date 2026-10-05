import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/features/chat/data/chat_models.dart';
import 'package:sportiva_app/features/matches/data/match_models.dart';
import 'package:sportiva_app/features/social/data/social_models.dart';

Map<String, dynamic> postJson({String status = 'Published', List<Map<String, dynamic>> media = const []}) => {
  'id': 'p1',
  'author': {'userId': 'u1', 'fullName': 'Ali Hassan', 'avatarUrl': null},
  'status': status,
  'hasVideo': media.any((m) => m['type'] == 'Video'),
  'media': media,
  'likesCount': 3,
  'commentsCount': 1,
  'viewsCount': 0,
  'isLiked': false,
  'isMine': false,
  'createdAt': '2026-10-01T10:00:00Z',
  'text': 'hello',
};

void main() {
  group('posts', () {
    test('a processing video is not playable yet, a ready one is', () {
      final processing = Post.fromJson(
        postJson(
          status: 'Processing',
          media: [
            {'type': 'Video', 'status': 'Processing', 'url': null},
          ],
        ),
      );
      expect(processing.status, PostStatus.processing);
      expect(processing.video, isNull);

      final ready = Post.fromJson(
        postJson(
          media: [
            {'type': 'Video', 'status': 'Ready', 'url': 'https://x/a.m3u8', 'fallbackUrl': 'https://x/a.mp4'},
            {'type': 'Image', 'status': 'Ready', 'url': 'https://x/i.jpg'},
          ],
        ),
      );
      expect(ready.video?.fallbackUrl, 'https://x/a.mp4');
      expect(ready.images, hasLength(1));
    });

    test('a patch changes only what it carries, and patches merge', () {
      final post = Post.fromJson(postJson());
      final liked = post.apply(const PostPatch(isLiked: true, likesCount: 4));
      expect((liked.isLiked, liked.likesCount, liked.commentsCount), (true, 4, 1));

      final merged = const PostPatch(isLiked: true, likesCount: 4).merge(const PostPatch(commentsCount: 2));
      final both = post.apply(merged);
      expect((both.isLiked, both.likesCount, both.commentsCount), (true, 4, 2));
      expect(const PostPatch().merge(const PostPatch(isDeleted: true)).isDeleted, isTrue);
    });
  });

  group('chat', () {
    ChatMessage message({String sender = 'a', String? receiver = 'b', String? match}) => ChatMessage.fromJson({
      'id': 1,
      'sender': {'userId': sender, 'fullName': 'X'},
      'receiverId': receiver,
      'matchId': match,
      'text': 'hi',
      'sentAt': '2026-10-01T10:00:00Z',
      'isMine': false,
    });

    test('a direct message belongs to the conversation with either side', () {
      expect(message().belongsTo(const ChatTarget.person('a')), isTrue);
      expect(message().belongsTo(const ChatTarget.person('b')), isTrue);
      expect(message().belongsTo(const ChatTarget.person('c')), isFalse);
      expect(message().belongsTo(const ChatTarget.match('m')), isFalse);
    });

    test('a match message belongs only to that match', () {
      final inMatch = message(receiver: null, match: 'm');
      expect(inMatch.belongsTo(const ChatTarget.match('m')), isTrue);
      expect(inMatch.belongsTo(const ChatTarget.match('other')), isFalse);
      expect(inMatch.belongsTo(const ChatTarget.person('a')), isFalse);
    });

    test('targets compare by value', () {
      expect(const ChatTarget.match('x') == const ChatTarget.match('x'), isTrue);
      expect(const ChatTarget.match('x') == const ChatTarget.person('x'), isFalse);
    });
  });

  group('matches', () {
    test('statuses parse and unknown ones count as cancelled', () {
      expect(MatchStatus.fromApi('Open'), MatchStatus.open);
      expect(MatchStatus.fromApi('InProgress'), MatchStatus.inProgress);
      expect(MatchStatus.fromApi('???'), MatchStatus.cancelled);
      expect(JoinRequestStatus.fromApi(null), isNull);
    });
  });
}

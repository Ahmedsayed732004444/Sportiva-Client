import 'player_traits.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/sport_type.dart';

class Person {
  const Person({required this.userId, required this.fullName, this.avatarUrl});

  final String userId;
  final String fullName;
  final String? avatarUrl;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    userId: json['userId'] as String,
    fullName: json['fullName'] as String? ?? '',
    avatarUrl: json['avatarUrl'] as String?,
  );
}

enum PostStatus { processing, published, failed }

class PostMedia {
  const PostMedia({
    required this.isVideo,
    required this.isReady,
    this.url,
    this.fallbackUrl,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  final bool isVideo;
  final bool isReady;
  // A video's url is the HLS playlist; fallbackUrl is the same video as MP4.
  final String? url;
  final String? fallbackUrl;
  final String? thumbnailUrl;
  final double? durationSeconds;

  factory PostMedia.fromJson(Map<String, dynamic> json) => PostMedia(
    isVideo: json['type'].toString() == 'Video',
    isReady: json['status'].toString() == 'Ready',
    url: json['url'] as String?,
    fallbackUrl: json['fallbackUrl'] as String?,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
  );
}

// What changed since the post was loaded (a like, a push from the server): shown on top of the loaded post.
class PostPatch {
  const PostPatch({
    this.likesCount,
    this.commentsCount,
    this.viewsCount,
    this.isLiked,
    this.isDeleted = false,
    this.text,
  });

  final int? likesCount;
  final int? commentsCount;
  final int? viewsCount;
  final bool? isLiked;
  final bool isDeleted;
  final String? text;

  PostPatch merge(PostPatch other) => PostPatch(
    likesCount: other.likesCount ?? likesCount,
    commentsCount: other.commentsCount ?? commentsCount,
    viewsCount: other.viewsCount ?? viewsCount,
    isLiked: other.isLiked ?? isLiked,
    isDeleted: other.isDeleted || isDeleted,
    text: other.text ?? text,
  );
}

class Post {
  const Post({
    required this.id,
    required this.author,
    required this.status,
    required this.hasVideo,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isLiked,
    required this.isMine,
    required this.createdAt,
    this.text,
    this.failureReason,
  });

  final String id;
  final Person author;
  final PostStatus status;
  final bool hasVideo;
  final List<PostMedia> media;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLiked;
  final bool isMine;
  final DateTime createdAt;
  final String? text;
  final String? failureReason;

  List<PostMedia> get images => media.where((m) => !m.isVideo && m.isReady).toList();
  PostMedia? get video => media.where((m) => m.isVideo && m.isReady).firstOrNull;

  Post apply(PostPatch? patch) => patch == null
      ? this
      : Post(
          id: id,
          author: author,
          status: status,
          hasVideo: hasVideo,
          media: media,
          likesCount: patch.likesCount ?? likesCount,
          commentsCount: patch.commentsCount ?? commentsCount,
          viewsCount: patch.viewsCount ?? viewsCount,
          isLiked: patch.isLiked ?? isLiked,
          isMine: isMine,
          createdAt: createdAt,
          text: patch.text ?? text,
          failureReason: failureReason,
        );

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as String,
    author: Person.fromJson(json['author'] as Map<String, dynamic>),
    status: switch (json['status'].toString()) {
      'Published' => PostStatus.published,
      'Failed' => PostStatus.failed,
      _ => PostStatus.processing,
    },
    hasVideo: json['hasVideo'] as bool? ?? false,
    media: (json['media'] as List? ?? const []).cast<Map<String, dynamic>>().map(PostMedia.fromJson).toList(),
    likesCount: json['likesCount'] as int? ?? 0,
    commentsCount: json['commentsCount'] as int? ?? 0,
    viewsCount: json['viewsCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    isMine: json['isMine'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
    text: json['text'] as String?,
    failureReason: json['failureReason'] as String?,
  );
}

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.canDelete,
    required this.isMine,
    required this.createdAt,
    this.parentId,
    this.replyTo,
  });

  final String id;
  final String postId;
  final Person author;
  final String text;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final bool canDelete;
  final bool isMine;
  final DateTime createdAt;
  final String? parentId;
  final Person? replyTo;

  Comment copyWith({int? likesCount, bool? isLiked, int? repliesCount}) => Comment(
    id: id,
    postId: postId,
    author: author,
    text: text,
    likesCount: likesCount ?? this.likesCount,
    repliesCount: repliesCount ?? this.repliesCount,
    isLiked: isLiked ?? this.isLiked,
    canDelete: canDelete,
    isMine: isMine,
    createdAt: createdAt,
    parentId: parentId,
    replyTo: replyTo,
  );

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String,
    postId: json['postId'] as String,
    author: Person.fromJson(json['author'] as Map<String, dynamic>),
    text: json['text'] as String? ?? '',
    likesCount: json['likesCount'] as int? ?? 0,
    repliesCount: json['repliesCount'] as int? ?? 0,
    isLiked: json['isLiked'] as bool? ?? false,
    canDelete: json['canDelete'] as bool? ?? false,
    isMine: json['isMine'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
    parentId: json['parentId'] as String?,
    replyTo: json['replyTo'] == null ? null : Person.fromJson(json['replyTo'] as Map<String, dynamic>),
  );
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isMe,
    required this.isFollowing,
    required this.followsYou,
    required this.isBlockedByMe,
    required this.preferredSports,
    this.position,
    this.foot,
    this.governorateId,
    this.bio,
    this.city,
    this.governorateName,
    this.avatarUrl,
    this.coverUrl,
    this.rating,
    this.reviewsCount = 0,
    this.isOnline,
  });

  final String userId;
  final String fullName;
  final String firstName;
  final String lastName;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isMe;
  final bool isFollowing;
  final bool followsYou;
  final bool isBlockedByMe;
  final List<SportType> preferredSports;
  final PlayerPosition? position;
  final PreferredFoot? foot;
  final int? governorateId;
  final String? bio;
  final String? city;
  final String? governorateName;
  final String? avatarUrl;
  final String? coverUrl;
  final double? rating;
  final int reviewsCount;
  // Only known between people who follow each other.
  final bool? isOnline;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] as String,
    fullName: json['fullName'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    followersCount: json['followersCount'] as int? ?? 0,
    followingCount: json['followingCount'] as int? ?? 0,
    postsCount: json['postsCount'] as int? ?? 0,
    isMe: json['isMe'] as bool? ?? false,
    isFollowing: json['isFollowing'] as bool? ?? false,
    followsYou: json['followsYou'] as bool? ?? false,
    isBlockedByMe: json['isBlockedByMe'] as bool? ?? false,
    preferredSports: (json['preferredSports'] as List? ?? const []).map(SportType.fromApi).toList(),
    position: PlayerPosition.fromApi(json['position']),
    foot: PreferredFoot.fromApi(json['preferredFoot']),
    governorateId: json['governorateId'] as int?,
    bio: json['bio'] as String?,
    city: json['city'] as String?,
    governorateName: json['governorateName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    reviewsCount: json['reviewsCount'] as int? ?? 0,
    isOnline: json['isOnline'] as bool?,
  );
}

class FollowItem {
  const FollowItem({required this.person, required this.isFollowing});

  final Person person;
  final bool isFollowing;

  factory FollowItem.fromJson(Map<String, dynamic> json) => FollowItem(
    person: Person.fromJson(json['person'] as Map<String, dynamic>),
    isFollowing: json['isFollowing'] as bool? ?? false,
  );
}

class Conversation {
  const Conversation({
    required this.with_,
    required this.lastText,
    required this.lastAt,
    required this.unreadCount,
    this.isOnline,
  });

  final Person with_;
  final String lastText;
  final DateTime lastAt;
  final int unreadCount;
  final bool? isOnline;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final last = json['lastMessage'] as Map<String, dynamic>;
    return Conversation(
      with_: Person.fromJson(json['with'] as Map<String, dynamic>),
      lastText: last['text'] as String? ?? '',
      lastAt: DateTime.tryParse(last['sentAt']?.toString() ?? '') ?? DateTime.now().toUtc(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool?,
    );
  }
}

enum ReportReason {
  sexualContent('SexualContent'),
  violence('Violence'),
  harassment('Harassment'),
  spam('Spam'),
  misinformation('Misinformation'),
  impersonation('Impersonation'),
  other('Other');

  const ReportReason(this.apiName);
  final String apiName;
}

class SearchResults {
  const SearchResults({required this.users, required this.clubs, required this.posts});

  final List<Person> users;
  final List<ClubRef> clubs;
  final List<Post> posts;

  bool get isEmpty => users.isEmpty && clubs.isEmpty && posts.isEmpty;

  factory SearchResults.fromJson(Map<String, dynamic> json) => SearchResults(
    users: (json['users'] as List).cast<Map<String, dynamic>>().map(Person.fromJson).toList(),
    clubs: (json['clubs'] as List).cast<Map<String, dynamic>>().map(ClubRef.fromJson).toList(),
    posts: (json['posts'] as List).cast<Map<String, dynamic>>().map(Post.fromJson).toList(),
  );
}

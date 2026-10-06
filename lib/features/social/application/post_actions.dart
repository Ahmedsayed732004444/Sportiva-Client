import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_exception.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';
import 'post_patches.dart';

// What a person does to a post from any screen that shows it. Each one updates the screen first and takes it back
// if the server says no, so the buttons feel instant.
class PostActions {
  PostActions(this._ref);

  final WidgetRef _ref;

  Future<void> toggleLike(Post shown) async {
    final patches = _ref.read(postPatchesProvider.notifier);
    patches.patch(
      shown.id,
      PostPatch(isLiked: !shown.isLiked, likesCount: shown.likesCount + (shown.isLiked ? -1 : 1)),
    );
    try {
      final result = await _ref.read(socialRepositoryProvider).toggleLike(shown.id);
      patches.patch(shown.id, PostPatch(isLiked: result.isLiked, likesCount: result.likesCount));
    } on Object {
      patches.patch(shown.id, PostPatch(isLiked: shown.isLiked, likesCount: shown.likesCount));
    }
  }

  // Returns the new state so the caller can say "saved" or "removed".
  Future<bool?> toggleSave(Post shown) async {
    final patches = _ref.read(postPatchesProvider.notifier);
    patches.patch(
      shown.id,
      PostPatch(isSaved: !shown.isSaved, savesCount: shown.savesCount + (shown.isSaved ? -1 : 1)),
    );
    try {
      final result = await _ref.read(socialRepositoryProvider).toggleSave(shown.id);
      patches.patch(shown.id, PostPatch(isSaved: result.isSaved, savesCount: result.savesCount));
      return result.isSaved;
    } on Object {
      patches.patch(shown.id, PostPatch(isSaved: shown.isSaved, savesCount: shown.savesCount));
      return null;
    }
  }

  Future<void> follow(Post shown) async {
    final follows = _ref.read(authorFollowsProvider.notifier);
    follows.set(shown.author.userId, true);
    try {
      final result = await _ref.read(socialRepositoryProvider).toggleFollow(shown.author.userId);
      follows.set(shown.author.userId, result.isFollowing);
      // The button only follows: a second tap by mistake must not unfollow.
      if (!result.isFollowing) await _ref.read(socialRepositoryProvider).toggleFollow(shown.author.userId);
      follows.set(shown.author.userId, true);
    } on ApiException {
      follows.set(shown.author.userId, false);
    }
  }

  Future<bool> share(Post shown, String appName) async {
    final media = shown.video?.fallbackUrl ?? shown.video?.url ?? shown.images.firstOrNull?.url;
    final text = [
      '${shown.author.fullName}${(shown.text?.isNotEmpty ?? false) ? ': ${shown.text}' : ''}',
      ?media,
      appName,
    ].join('\n');
    try {
      await SharePlus.instance.share(ShareParams(text: text));
      return true;
    } on Object {
      return false;
    }
  }
}

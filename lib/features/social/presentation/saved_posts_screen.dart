import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import 'widgets/post_card.dart';

// The posts the person kept in their favourites.
class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedPosts)),
      body: PagedListView<Post>(
        state: savedPostsProvider,
        actions: savedPostsProvider.notifier,
        emptyMessage: l10n.noSavedPosts,
        emptyIcon: Icons.bookmark_border,
        separator: const SizedBox(height: AppSpacing.s),
        itemBuilder: (context, post) => PostCard(post: post),
      ),
    );
  }
}

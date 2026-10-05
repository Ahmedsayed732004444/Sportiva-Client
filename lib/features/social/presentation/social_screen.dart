import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../chat/application/chat_controller.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import 'reels_view.dart';
import 'widgets/post_card.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unread = ref.watch(unreadMessagesProvider).valueOrNull ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navSocial),
          actions: [
            IconButton(
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              tooltip: l10n.searchHint,
            ),
            IconButton(
              onPressed: () => context.push('/messages'),
              tooltip: l10n.messages,
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
            const NotificationBell(),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.black600,
            indicatorColor: AppColors.primary,
            labelStyle: AppTextStyles.body1Semibold,
            unselectedLabelStyle: AppTextStyles.body1,
            tabs: [
              Tab(text: l10n.feed),
              Tab(text: l10n.explore),
              Tab(text: l10n.reels),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/post/create'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBrand,
          tooltip: l10n.newPost,
          child: const Icon(Icons.edit_outlined),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                const _NewPostsBanner(),
                Expanded(
                  child: PagedListView<Post>(
                    state: feedProvider,
                    actions: feedProvider.notifier,
                    emptyMessage: l10n.noPosts,
                    emptyIcon: Icons.dynamic_feed_outlined,
                    separator: const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, post) => PostCard(post: post),
                  ),
                ),
              ],
            ),
            PagedListView<Post>(
              state: exploreProvider,
              actions: exploreProvider.notifier,
              emptyMessage: l10n.noPosts,
              emptyIcon: Icons.explore_outlined,
              separator: const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, post) => PostCard(post: post),
            ),
            const ReelsView(),
          ],
        ),
      ),
    );
  }
}

class _NewPostsBanner extends ConsumerWidget {
  const _NewPostsBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(newPostsCountProvider) == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: ActionChip(
        avatar: const Icon(Icons.arrow_upward, size: 16, color: AppColors.onBrand),
        label: Text(context.l10n.showNewPosts, style: AppTextStyles.body2.copyWith(color: AppColors.onBrand)),
        backgroundColor: AppColors.primary,
        side: BorderSide.none,
        onPressed: ref.read(feedProvider.notifier).refresh,
      ),
    );
  }
}

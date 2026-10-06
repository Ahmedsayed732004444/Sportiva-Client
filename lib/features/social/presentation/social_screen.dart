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

// Following, explore, and "for you". The last one is a full-screen pager, so the bar floats over it with its tabs in
// white: the tabs stay where they are on every page, like on TikTok.
class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 3, vsync: this);
  bool _overlay = false;

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      final onPager = _tabs.index == 2 || (_tabs.animation?.value ?? 0) > 1.5;
      if (onPager != _overlay) setState(() => _overlay = onPager);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unread = ref.watch(unreadMessagesProvider).valueOrNull ?? 0;
    final ink = _overlay ? AppColors.onBrand : AppColors.ink;

    return Scaffold(
      extendBodyBehindAppBar: _overlay,
      appBar: AppBar(
        backgroundColor: _overlay ? Colors.transparent : null,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        iconTheme: IconThemeData(
          color: ink,
          shadows: _overlay ? const [Shadow(color: Color(0x99000000), blurRadius: 6)] : null,
        ),
        actionsIconTheme: IconThemeData(
          color: ink,
          shadows: _overlay ? const [Shadow(color: Color(0x99000000), blurRadius: 6)] : null,
        ),
        flexibleSpace: _overlay
            ? const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99000000), Color(0x00000000)],
                  ),
                ),
              )
            : null,
        title: Text(
          l10n.navSocial,
          style: AppTextStyles.title.copyWith(color: ink, fontWeight: FontWeight.w700),
        ),
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
          controller: _tabs,
          labelColor: _overlay ? AppColors.onBrand : AppColors.primary,
          unselectedLabelColor: _overlay ? AppColors.onBrand.withValues(alpha: 0.7) : AppColors.black600,
          indicatorColor: _overlay ? AppColors.onBrand : AppColors.primary,
          dividerColor: _overlay ? Colors.transparent : null,
          labelStyle: AppTextStyles.body1Semibold,
          unselectedLabelStyle: AppTextStyles.body1,
          tabs: [
            Tab(text: l10n.feed),
            Tab(text: l10n.explore),
            Tab(text: l10n.reels),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
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

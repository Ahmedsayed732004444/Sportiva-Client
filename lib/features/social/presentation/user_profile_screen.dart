import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';
import '../data/social_repository.dart';
import 'report_sheet.dart';
import 'widgets/post_card.dart';

enum _ProfileAction { report, block, unblock }

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (profile.valueOrNull case final loaded? when !loaded.isMe)
            PopupMenuButton<_ProfileAction>(
              onSelected: (action) => _onAction(context, ref, loaded, action),
              itemBuilder: (_) => [
                PopupMenuItem(value: _ProfileAction.report, child: Text(l10n.report)),
                PopupMenuItem(
                  value: loaded.isBlockedByMe ? _ProfileAction.unblock : _ProfileAction.block,
                  child: Text(loaded.isBlockedByMe ? l10n.unblock : l10n.block),
                ),
              ],
            ),
        ],
      ),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(profileProvider(userId)),
        ),
        data: (profile) => PagedListView<Post>(
          state: userPostsProvider(userId),
          actions: userPostsProvider(userId).notifier,
          emptyMessage: l10n.noPosts,
          emptyIcon: Icons.dynamic_feed_outlined,
          padding: const EdgeInsets.only(bottom: AppSpacing.l),
          separator: const SizedBox(height: AppSpacing.s),
          header: _Header(profile: profile),
          itemBuilder: (context, post) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: PostCard(post: post),
          ),
        ),
      ),
    );
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, UserProfile profile, _ProfileAction action) async {
    final l10n = context.l10n;
    final repository = ref.read(socialRepositoryProvider);

    try {
      switch (action) {
        case _ProfileAction.report:
          await reportContent(context, repository, targetType: 'User', targetId: profile.userId);
        case _ProfileAction.block:
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.block),
              content: Text(l10n.blockBody),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.block, style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
          await repository.block(profile.userId);
          ref.invalidate(profileProvider(userId));
          ref.invalidate(feedProvider);
          if (context.mounted) showSnack(context, l10n.blocked);
        case _ProfileAction.unblock:
          await repository.unblock(profile.userId);
          ref.invalidate(profileProvider(userId));
      }
    } on ApiException catch (e) {
      if (context.mounted) showApiError(context, e);
    }
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _busy = false;

  Future<void> _toggleFollow() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(socialRepositoryProvider).toggleFollow(widget.profile.userId);
      ref.invalidate(profileProvider(widget.profile.userId));
    } on ApiException catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = widget.profile;

    Widget stat(String label, int value, {VoidCallback? onTap}) => Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              Text('$value', style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
            ],
          ),
        ),
      ),
    );

    return Column(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: AppNetworkImage(url: profile.coverUrl, icon: Icons.landscape_outlined),
        ),
        Transform.translate(
          offset: const Offset(0, -36),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 4),
                ),
                child: UserAvatar(name: profile.fullName, url: profile.avatarUrl, radius: 44),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(profile.fullName, style: AppTextStyles.header),
              if (profile.isOnline ?? false)
                Text(l10n.online, style: AppTextStyles.caption.copyWith(color: AppColors.primaryMid)),
              if (profile.rating != null) RatingBadge(rating: profile.rating, count: profile.reviewsCount),
              if (profile.bio?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xs, AppSpacing.l, 0),
                  child: Text(profile.bio!, textAlign: TextAlign.center, style: AppTextStyles.body1),
                ),
              if (profile.city != null || profile.governorateName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [profile.city, profile.governorateName].whereType<String>().join('، '),
                    style: AppTextStyles.body2.copyWith(color: AppColors.black600),
                  ),
                ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  stat(l10n.postsLabel, profile.postsCount),
                  stat(
                    l10n.followers,
                    profile.followersCount,
                    onTap: () => context.push('/user/${profile.userId}/followers'),
                  ),
                  stat(
                    l10n.followingLabel,
                    profile.followingCount,
                    onTap: () => context.push('/user/${profile.userId}/following'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: profile.isMe
                    ? AppButton(
                        label: l10n.editProfile,
                        style: AppButtonStyle.outlined,
                        onPressed: () => context.push('/profile/edit'),
                      )
                    : profile.isBlockedByMe
                    ? Text(l10n.blockedProfile, style: AppTextStyles.body2.copyWith(color: AppColors.error))
                    : Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: profile.isFollowing
                                  ? l10n.following
                                  : (profile.followsYou ? l10n.followBack : l10n.follow),
                              style: profile.isFollowing ? AppButtonStyle.outlined : AppButtonStyle.filled,
                              isLoading: _busy,
                              onPressed: _toggleFollow,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: AppButton(
                              label: l10n.message,
                              style: AppButtonStyle.outlined,
                              onPressed: () => context.push('/chat/${profile.userId}'),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

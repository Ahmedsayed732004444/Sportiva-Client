import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/social_controllers.dart';
import 'widgets/post_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final results = ref.watch(searchProvider);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.m, AppSpacing.s, AppSpacing.xs),
      child: Text(text, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: AppTextStyles.body1,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (text) => ref.read(searchTextProvider.notifier).state = text,
        ),
      ),
      body: results.when(
        loading: () => const LoadingView(),
        // A newer search replaced this one: nothing to show for the old one.
        error: (error, _) => error is StateError
            ? const LoadingView()
            : ErrorView(
                error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
                onRetry: () => ref.invalidate(searchProvider),
              ),
        data: (found) {
          if (found == null) return EmptyView(message: l10n.typeToSearch, icon: Icons.search);
          if (found.isEmpty) return EmptyView(message: l10n.noResults, icon: Icons.search_off);

          return ListView(
            children: [
              if (found.users.isNotEmpty) heading(l10n.searchPeople),
              for (final user in found.users)
                ListTile(
                  leading: UserAvatar(name: user.fullName, url: user.avatarUrl),
                  title: Text(user.fullName),
                  onTap: () => context.push('/user/${user.userId}'),
                ),
              if (found.clubs.isNotEmpty) heading(l10n.searchClubs),
              for (final club in found.clubs)
                ListTile(
                  leading: SizedBox(
                    width: 44,
                    height: 44,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(url: club.logoUrl),
                    ),
                  ),
                  title: Text(club.name),
                  onTap: () => context.push('/club/${club.id}'),
                ),
              if (found.posts.isNotEmpty) heading(l10n.searchPosts),
              for (final post in found.posts)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s, 0, AppSpacing.s, AppSpacing.s),
                  child: PostCard(post: post),
                ),
            ],
          );
        },
      ),
    );
  }
}

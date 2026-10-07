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
import 'widgets/suggested_people.dart';

enum _Kind { all, people, clubs, posts }

final _kindProvider = StateProvider.autoDispose<_Kind>((ref) => _Kind.all);

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final results = ref.watch(searchProvider);
    final kind = ref.watch(_kindProvider);
    bool show(_Kind k) => kind == _Kind.all || kind == k;

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
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 6),
              children: [
                for (final (k, label) in [
                  (_Kind.all, l10n.searchAll),
                  (_Kind.people, l10n.searchPeople),
                  (_Kind.clubs, l10n.searchClubs),
                  (_Kind.posts, l10n.searchPosts),
                ])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: kind == k,
                      onSelected: (_) => ref.read(_kindProvider.notifier).state = k,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const LoadingView(),
              // A newer search replaced this one: nothing to show for the old one.
              error: (error, _) => error is StateError
                  ? const LoadingView()
                  : ErrorView(
                      error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
                      onRetry: () => ref.invalidate(searchProvider),
                    ),
              data: (found) {
                if (found == null) {
                  return ListView(padding: const EdgeInsets.all(AppSpacing.s), children: const [SuggestedPeople()]);
                }
                if (found.isEmpty) return EmptyView(message: l10n.noResults, icon: Icons.search_off);

                return ListView(
                  children: [
                    if (show(_Kind.people) && found.users.isNotEmpty) heading(l10n.searchPeople),
                    if (show(_Kind.people))
                      for (final user in found.users)
                        ListTile(
                          leading: UserAvatar(name: user.fullName, url: user.avatarUrl),
                          title: Text(user.fullName),
                          onTap: () => context.push('/user/${user.userId}'),
                        ),
                    if (show(_Kind.clubs) && found.clubs.isNotEmpty) heading(l10n.searchClubs),
                    if (show(_Kind.clubs))
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
                    if (show(_Kind.posts) && found.posts.isNotEmpty) heading(l10n.searchPosts),
                    if (show(_Kind.posts))
                      for (final post in found.posts)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.s, 0, AppSpacing.s, AppSpacing.s),
                          child: PostCard(post: post),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

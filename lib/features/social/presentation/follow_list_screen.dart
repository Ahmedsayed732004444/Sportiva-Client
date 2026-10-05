import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';

class FollowListScreen extends StatelessWidget {
  const FollowListScreen({super.key, required this.userId, required this.followers});

  final String userId;
  final bool followers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = followListProvider((userId: userId, followers: followers));

    return Scaffold(
      appBar: AppBar(title: Text(followers ? l10n.followers : l10n.followingOf)),
      body: PagedListView<FollowItem>(
        state: provider,
        actions: provider.notifier,
        emptyMessage: l10n.noPeople,
        emptyIcon: Icons.people_outline,
        itemBuilder: (context, item) => ListTile(
          leading: UserAvatar(name: item.person.fullName, url: item.person.avatarUrl),
          title: Text(item.person.fullName),
          onTap: () => context.push('/user/${item.person.userId}'),
        ),
      ),
    );
  }
}

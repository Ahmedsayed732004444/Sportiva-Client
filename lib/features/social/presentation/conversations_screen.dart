import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/social_controllers.dart';
import '../data/social_models.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messages)),
      body: PagedListView<Conversation>(
        state: conversationsProvider,
        actions: conversationsProvider.notifier,
        emptyMessage: l10n.noConversations,
        emptyIcon: Icons.chat_bubble_outline,
        itemBuilder: (context, conversation) => ListTile(
          leading: Badge(
            isLabelVisible: conversation.isOnline ?? false,
            smallSize: 10,
            backgroundColor: AppColors.primaryMid,
            child: UserAvatar(name: conversation.with_.fullName, url: conversation.with_.avatarUrl),
          ),
          title: Text(conversation.with_.fullName, style: AppTextStyles.body1Semibold),
          subtitle: Text(conversation.lastText, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(relativeTime(l10n, conversation.lastAt), style: AppTextStyles.caption),
              if (conversation.unreadCount > 0)
                Badge(label: Text('${conversation.unreadCount}'), backgroundColor: AppColors.primary),
            ],
          ),
          onTap: () => context.push('/chat/${conversation.with_.userId}'),
        ),
      ),
    );
  }
}

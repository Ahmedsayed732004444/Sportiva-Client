import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../chat/data/chat_models.dart';
import '../../chat/presentation/chat_view.dart';

class MatchChatScreen extends StatelessWidget {
  const MatchChatScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.openChat)),
    body: ChatView(target: ChatTarget.match(matchId)),
  );
}

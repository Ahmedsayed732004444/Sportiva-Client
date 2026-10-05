import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../chat/data/chat_models.dart';
import '../../chat/presentation/chat_view.dart';
import '../application/social_controllers.dart';

class DirectChatScreen extends ConsumerWidget {
  const DirectChatScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider(userId)).valueOrNull?.fullName ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ChatView(target: ChatTarget.person(userId)),
    );
  }
}

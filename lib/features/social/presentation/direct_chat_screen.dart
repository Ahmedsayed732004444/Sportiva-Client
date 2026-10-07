import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../chat/application/chat_controller.dart';
import '../../chat/data/chat_models.dart';
import '../../chat/presentation/chat_view.dart';
import '../application/social_controllers.dart';

class DirectChatScreen extends ConsumerStatefulWidget {
  const DirectChatScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends ConsumerState<DirectChatScreen> {
  late final StateController<String?> _open = ref.read(openChatUserProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _open.state = widget.userId);
  }

  @override
  void dispose() {
    final open = _open;
    final id = widget.userId;
    Future.microtask(() {
      if (open.state == id) open.state = null;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(profileProvider(widget.userId)).valueOrNull?.fullName ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ChatView(target: ChatTarget.person(widget.userId)),
    );
  }
}

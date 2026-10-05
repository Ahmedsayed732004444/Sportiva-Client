import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/realtime/realtime_service.dart';
import '../data/chat_models.dart';
import '../data/chat_repository.dart';

class ChatState {
  const ChatState({this.messages = const [], this.page = 0, this.hasMore = true, this.isLoading = false, this.error});

  // Newest first, as the API returns them.
  final List<ChatMessage> messages;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final ApiException? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    int? page,
    bool? hasMore,
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
  );
}

// One chat: history in pages, new messages arrive live. Opening a conversation with a person marks it read.
class ChatController extends AutoDisposeFamilyNotifier<ChatState, ChatTarget> {
  @override
  ChatState build(ChatTarget target) {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.messageReceived && event.json != null) {
        final message = ChatMessage.fromJson(event.json!);
        if (message.belongsTo(target)) {
          _add(message);
          if (!target.isMatch && !message.isMine) _markRead();
        }
      } else if (event.name == RealtimeEvents.reconnected) {
        _reload();
      }
    });
    ref.onDispose(subscription.cancel);

    Future.microtask(() async {
      await loadOlder();
      if (!target.isMatch) _markRead();
    });
    return const ChatState();
  }

  Future<void> loadOlder() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final next = state.page + 1;
      final result = await ref.read(chatRepositoryProvider).messages(arg, page: next);
      final known = state.messages.map((m) => m.id).toSet();
      state = state.copyWith(
        messages: [...state.messages, ...result.items.where((m) => !known.contains(m.id))],
        page: next,
        hasMore: result.hasMore,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> send(String text) async => _add(await ref.read(chatRepositoryProvider).send(arg, text));

  void _add(ChatMessage message) {
    if (state.messages.any((m) => m.id == message.id)) return;
    state = state.copyWith(messages: [message, ...state.messages]);
  }

  Future<void> _reload() async {
    state = const ChatState();
    await loadOlder();
  }

  Future<void> _markRead() async {
    try {
      await ref.read(chatRepositoryProvider).markRead(arg.id);
    } on ApiException {
      // Not being able to mark it read is not worth interrupting the chat.
    }
  }
}

final chatProvider = AutoDisposeNotifierProviderFamily<ChatController, ChatState, ChatTarget>(ChatController.new);

// The unread direct messages, for the badge on the messages button.
final unreadMessagesProvider = FutureProvider.autoDispose<int>((ref) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    const names = {RealtimeEvents.messageReceived, RealtimeEvents.messagesRead, RealtimeEvents.reconnected};
    if (names.contains(event.name)) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  return ref.read(chatRepositoryProvider).unreadCount();
});

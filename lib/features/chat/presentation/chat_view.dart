import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

// The body of a chat screen (messages and the box to write in), the same for a match group and for a person.
class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key, required this.target});

  final ChatTarget target;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> with SubmitMixin {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;

    final done = await submit(() => ref.read(chatProvider(widget.target).notifier).send(text));
    if (done) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chat = ref.watch(chatProvider(widget.target));
    final controller = ref.read(chatProvider(widget.target).notifier);

    return Column(
      children: [
        Expanded(
          child: chat.messages.isEmpty
              ? (chat.isLoading
                    ? const LoadingView()
                    : EmptyView(message: l10n.noMessages, icon: Icons.chat_bubble_outline))
              : NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    // The list is upside down: its "end" is the oldest message.
                    if (scroll.metrics.extentAfter < 200) controller.loadOlder();
                    return false;
                  },
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(AppSpacing.s),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) =>
                        _Bubble(message: chat.messages[index], showSender: widget.target.isMatch),
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: AppTextStyles.body1,
                    decoration: InputDecoration(hintText: l10n.typeMessage),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton.filled(
                  onPressed: isSubmitting ? null : _send,
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.send_rounded, color: AppColors.onBrand),
                  tooltip: l10n.send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.showSender});

  final ChatMessage message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;

    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.gray200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSender && !mine)
              Text(
                message.senderName,
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryMid, fontWeight: FontWeight.w700),
              ),
            Text(message.text, style: AppTextStyles.body1.copyWith(color: mine ? AppColors.onBrand : AppColors.ink)),
            Text(
              relativeTime(context.l10n, message.sentAt),
              style: AppTextStyles.small.copyWith(
                color: mine ? AppColors.onBrand.withValues(alpha: 0.7) : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

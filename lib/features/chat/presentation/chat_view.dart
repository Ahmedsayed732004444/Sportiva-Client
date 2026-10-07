import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/chat_controller.dart';
import '../data/chat_models.dart';

const _maxVoice = Duration(seconds: 30);
const _readBlue = Color(0xFF53BDEB);

// The body of a chat screen (messages and the box to write in), the same for a match group and for a person.
// With nothing typed the send button becomes a microphone: a voice note of up to 30 seconds (recording stops there).
class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key, required this.target});

  final ChatTarget target;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

enum _Voice { idle, recording, recorded }

class _ChatViewState extends ConsumerState<ChatView> with SubmitMixin {
  final _text = TextEditingController();
  final _recorder = AudioRecorder();
  final _watch = Stopwatch();
  Timer? _ticker;
  _Voice _voice = _Voice.idle;
  String? _voicePath;

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;

    final done = await submit(() => ref.read(chatProvider(widget.target).notifier).send(text));
    if (done) _text.clear();
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      showMessage(context.l10n.micPermission);
      return;
    }
    final folder = await getTemporaryDirectory();
    final path = '${folder.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, numChannels: 1), path: path);
    _watch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_watch.elapsed >= _maxVoice) {
        _stopRecording();
        showMessage(context.l10n.voiceMaxReached);
      } else if (mounted) {
        setState(() {});
      }
    });
    setState(() => _voice = _Voice.recording);
  }

  Future<void> _stopRecording() async {
    _ticker?.cancel();
    _watch.stop();
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _voicePath = path;
      _voice = path == null ? _Voice.idle : _Voice.recorded;
    });
  }

  Future<void> _cancelVoice() async {
    _ticker?.cancel();
    _watch.stop();
    if (_voice == _Voice.recording) await _recorder.cancel();
    final path = _voicePath;
    if (path != null) File(path).delete().ignore();
    if (mounted) {
      setState(() {
        _voice = _Voice.idle;
        _voicePath = null;
      });
    }
  }

  Future<void> _sendVoice() async {
    if (_voice == _Voice.recording) await _stopRecording();
    final path = _voicePath;
    if (path == null) return;
    final seconds = _watch.elapsed.inSeconds.clamp(1, _maxVoice.inSeconds);

    final done = await submit(() => ref.read(chatProvider(widget.target).notifier).sendVoice(path, seconds));
    if (done && mounted) {
      File(path).delete().ignore();
      setState(() {
        _voice = _Voice.idle;
        _voicePath = null;
      });
    }
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
                    itemBuilder: (context, index) => _Bubble(
                      key: ValueKey(chat.messages[index].id),
                      message: chat.messages[index],
                      showSender: widget.target.isMatch,
                      showTicks: !widget.target.isMatch,
                    ),
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: _voice == _Voice.idle ? _composer(l10n) : _voiceBar(l10n),
          ),
        ),
      ],
    );
  }

  Widget _composer(dynamic l10n) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: _text,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _send(),
          minLines: 1,
          maxLines: 4,
          style: AppTextStyles.body1,
          decoration: InputDecoration(hintText: l10n.typeMessage as String),
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      ValueListenableBuilder(
        valueListenable: _text,
        builder: (context, value, _) {
          final typing = value.text.trim().isNotEmpty;
          return IconButton.filled(
            onPressed: isSubmitting ? null : (typing ? _send : _startRecording),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(48, 48)),
            icon: Icon(typing ? Icons.send_rounded : Icons.mic, color: AppColors.onBrand),
            tooltip: typing ? l10n.send as String : l10n.recordVoice as String,
          );
        },
      ),
    ],
  );

  Widget _voiceBar(dynamic l10n) {
    final elapsed = _watch.elapsed > _maxVoice ? _maxVoice : _watch.elapsed;
    final recording = _voice == _Voice.recording;
    String clock(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: [
          IconButton(
            onPressed: _cancelVoice,
            tooltip: l10n.voiceCancel as String,
            icon: Icon(Icons.delete_outline, color: AppColors.error),
          ),
          if (recording) Icon(Icons.fiber_manual_record, color: AppColors.error, size: 14),
          const SizedBox(width: 6),
          Text('${clock(elapsed)} / ${clock(_maxVoice)}', style: AppTextStyles.body1Semibold),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: elapsed.inMilliseconds / _maxVoice.inMilliseconds,
                minHeight: 6,
                color: recording ? AppColors.error : AppColors.primary,
                backgroundColor: AppColors.gray400.withValues(alpha: 0.4),
              ),
            ),
          ),
          if (recording)
            IconButton(
              onPressed: _stopRecording,
              icon: Icon(Icons.stop_circle_outlined, color: AppColors.ink),
            ),
          IconButton.filled(
            onPressed: isSubmitting ? null : _sendVoice,
            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            tooltip: l10n.voiceSend as String,
            icon: const Icon(Icons.send_rounded, color: AppColors.onBrand),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.message, required this.showSender, required this.showTicks});

  final ChatMessage message;
  final bool showSender;
  final bool showTicks;

  static final _matchLink = RegExp(r'/match/([0-9a-fA-F-]{36})');

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final ink = mine ? AppColors.onBrand : AppColors.ink;
    final faint = mine ? AppColors.onBrand.withValues(alpha: 0.75) : AppColors.gray500;
    final locale = Localizations.localeOf(context).languageCode;
    final link = _matchLink.firstMatch(message.text);

    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.gray200,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(16),
            topEnd: const Radius.circular(16),
            bottomStart: Radius.circular(mine ? 16 : 4),
            bottomEnd: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSender && !mine)
              Text(
                message.senderName,
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryMid, fontWeight: FontWeight.w700),
              ),
            if (message.isVoice)
              _VoicePlayer(url: message.audioUrl!, seconds: message.audioSeconds ?? 0, color: ink)
            else
              Text(message.text, style: AppTextStyles.body1.copyWith(color: ink)),
            if (link != null)
              TextButton.icon(
                onPressed: () => context.push('/match/${link.group(1)}'),
                style: TextButton.styleFrom(
                  foregroundColor: ink,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.sports_soccer, size: 18),
                label: Text(
                  context.l10n.openMatch,
                  style: AppTextStyles.body2.copyWith(color: ink, fontWeight: FontWeight.w700),
                ),
              ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(locale, _hms(message.sentAt.toLocal())),
                  style: AppTextStyles.small.copyWith(color: faint),
                ),
                if (mine && showTicks) ...[
                  const SizedBox(width: 4),
                  // Like WhatsApp: one tick sent, two ticks reached the phone, two blue ticks read.
                  Icon(
                    message.readAt != null || message.deliveredAt != null ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.readAt != null ? _readBlue : faint,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _hms(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}

// A voice note in a bubble: play / pause and how far it got. The player is made on the first tap only.
class _VoicePlayer extends StatefulWidget {
  const _VoicePlayer({required this.url, required this.seconds, required this.color});

  final String url;
  final int seconds;
  final Color color;

  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _state;
  StreamSubscription<Duration>? _position;
  bool _playing = false;
  bool _loading = false;
  Duration _at = Duration.zero;

  @override
  void dispose() {
    _state?.cancel();
    _position?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    var player = _player;
    if (player == null) {
      setState(() => _loading = true);
      player = AudioPlayer();
      _player = player;
      _state = player.playerStateStream.listen((state) {
        if (!mounted) return;
        if (state.processingState == ProcessingState.completed) {
          player!.pause();
          player.seek(Duration.zero);
        }
        setState(() => _playing = state.playing && state.processingState != ProcessingState.completed);
      });
      _position = player.positionStream.listen((position) {
        if (mounted) setState(() => _at = position);
      });
      try {
        await player.setUrl(widget.url);
      } on Object {
        if (mounted) setState(() => _loading = false);
        return;
      }
      if (mounted) setState(() => _loading = false);
    }
    _playing ? await player.pause() : await player.play();
  }

  @override
  Widget build(BuildContext context) {
    final total = Duration(seconds: widget.seconds);
    final shown = _playing || _at > Duration.zero ? _at : total;
    final progress = total.inMilliseconds == 0 ? 0.0 : (_at.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: 210,
      child: Row(
        children: [
          InkResponse(
            onTap: _loading ? null : _toggle,
            child: _loading
                ? SizedBox.square(
                    dimension: 32,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CircularProgressIndicator(strokeWidth: 2, color: widget.color),
                    ),
                  )
                : Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 36, color: widget.color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                color: widget.color,
                backgroundColor: widget.color.withValues(alpha: 0.25),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${shown.inMinutes}:${(shown.inSeconds % 60).toString().padLeft(2, '0')}',
            style: AppTextStyles.caption.copyWith(color: widget.color),
          ),
          const SizedBox(width: 4),
          Icon(Icons.mic, size: 16, color: widget.color.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}

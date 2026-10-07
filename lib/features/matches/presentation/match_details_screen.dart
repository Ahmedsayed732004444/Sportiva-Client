import '../../social/presentation/person_picker_sheet.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/data/chat_models.dart';
import '../../../core/widgets/snack.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../application/matches_controller.dart';
import '../data/match_models.dart';
import '../../auth/application/auth_controller.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/presentation/rating_sheet.dart';
import '../../social/data/social_models.dart';
import '../data/match_repository.dart';
import 'match_labels.dart';

class MatchDetailsScreen extends ConsumerWidget {
  const MatchDetailsScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.matchDetails),
        actions: [
          if (match.valueOrNull case final loaded? when loaded.isMember && loaded.status != MatchStatus.cancelled)
            _ShareMatchButton(match: loaded),
        ],
      ),
      body: match.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(matchProvider(matchId)),
        ),
        data: (match) => _Body(match: match),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.match});

  final FriendlyMatch match;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> with SubmitMixin {
  FriendlyMatch get match => widget.match;

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    final ok = await submit(action);
    if (!mounted || !ok) return;
    if (done != null) showMessage(done);
    ref.invalidate(matchProvider(match.id));
  }

  Future<void> _cancelMatch() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelMatch),
        content: Text(l10n.cancelMatchBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.keepBooking)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cancelMatch, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() => ref.read(matchRepositoryProvider).cancel(match.id, null), done: l10n.matchCancelled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final repository = ref.read(matchRepositoryProvider);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body1Semibold)),
        ],
      ),
    );

    final place = match.isExternal
        ? [match.placeName, match.address, match.city].whereType<String>().join('، ')
        : match.title;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(match.sport.icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(child: Text(match.sport.label(l10n), style: AppTextStyles.header)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: match.status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                match.status.label(l10n),
                style: AppTextStyles.caption.copyWith(color: match.status.color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (match.waitingForClub)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(l10n.waitingClubConfirm, style: AppTextStyles.body2.copyWith(color: AppColors.primaryMid)),
          ),
        const SizedBox(height: AppSpacing.m),
        row(l10n.club, place),
        row(l10n.dateLabel, formatLongDay(locale, parseApiDay(match.day))),
        row(l10n.timeLabel, l10n.timeRange(formatTime(locale, match.startTime), formatTime(locale, match.endTime))),
        row(l10n.organizer, match.organizer.fullName),
        row(l10n.players, l10n.playersCount(match.acceptedPlayers, match.playersNeeded)),
        if (match.note?.isNotEmpty ?? false) row(l10n.note, match.note!),
        const SizedBox(height: AppSpacing.m),
        Text(l10n.players, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xs),
        for (final player in [match.organizer, ...match.players.where((p) => p.userId != match.organizer.userId)])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UserAvatar(name: player.fullName, url: player.avatarUrl),
            title: Text(player.fullName, style: AppTextStyles.body1),
            subtitle: player.userId == match.organizer.userId
                ? Text(l10n.organizer, style: AppTextStyles.caption.copyWith(color: AppColors.primaryMid))
                : null,
            trailing: RatingBadge(rating: player.rating, count: player.reviewsCount),
          ),
        if (match.isOrganizer) _JoinRequests(match: match),
        const SizedBox(height: AppSpacing.l),
        if (match.isMember && match.status != MatchStatus.cancelled)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: AppButton(
              label: l10n.openChat,
              style: AppButtonStyle.outlined,
              onPressed: () => context.push('/match/${match.id}/chat'),
            ),
          ),
        if (match.canReview)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: AppButton(
              label: l10n.ratePlayers,
              style: AppButtonStyle.outlined,
              onPressed: () {
                final me = ref.read(authControllerProvider).valueOrNull?.userId;
                showPlayersRatingSheet(
                  context,
                  players: [
                    for (final p in [
                      match.organizer,
                      ...match.players.where((p) => p.userId != match.organizer.userId),
                    ])
                      if (p.userId != me) Person(userId: p.userId, fullName: p.fullName),
                  ],
                  submit: (playerId, rating, comment) =>
                      ref.read(reviewRepositoryProvider).rateMatchPlayer(match.id, playerId, rating, comment),
                );
              },
            ),
          ),
        if (match.canJoin)
          AppButton(
            label: l10n.requestToJoin,
            isLoading: isSubmitting,
            onPressed: () => _run(() => repository.requestToJoin(match.id), done: l10n.requestSent),
          ),
        if (match.canLeave && !match.isOrganizer)
          AppButton(
            label: match.myRequestStatus == JoinRequestStatus.pending ? l10n.cancelRequest : l10n.leaveMatch,
            style: AppButtonStyle.outlined,
            isLoading: isSubmitting,
            onPressed: () => _run(() => repository.leave(match.id)),
          ),
        if (match.canCancel) ...[
          const SizedBox(height: AppSpacing.s),
          AppButton(label: l10n.cancelMatch, isLoading: isSubmitting, onPressed: _cancelMatch),
        ],
      ],
    );
  }
}

class _JoinRequests extends ConsumerWidget {
  const _JoinRequests({required this.match});

  final FriendlyMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final requests = ref.watch(joinRequestsProvider(match.id));
    final repository = ref.read(matchRepositoryProvider);

    Future<void> answer(Future<void> Function() action) async {
      try {
        await action();
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.messageFor(l10n) ?? l10n.unknownError)));
        }
      }
      ref.invalidate(joinRequestsProvider(match.id));
      ref.invalidate(matchProvider(match.id));
    }

    final pending =
        requests.valueOrNull?.where((r) => r.status == JoinRequestStatus.pending).toList() ?? const <JoinRequest>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.m),
        Text(l10n.joinRequests, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        if (requests.isLoading) const SizedBox(height: 60, child: LoadingView()),
        if (!requests.isLoading && pending.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(l10n.noRequests, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          ),
        for (final request in pending)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(request.player.fullName, style: AppTextStyles.body1),
            subtitle: RatingBadge(rating: request.player.rating, count: request.player.reviewsCount),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => answer(() => repository.reject(match.id, request.id)),
                  icon: Icon(Icons.close, color: AppColors.error),
                  tooltip: l10n.reject,
                ),
                IconButton(
                  onPressed: match.spotsLeft > 0 ? () => answer(() => repository.accept(match.id, request.id)) : null,
                  icon: Icon(Icons.check, color: AppColors.primary),
                  tooltip: l10n.accept,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Members can bring people in: send the match to a friend in a chat, or share it outside the app.
class _ShareMatchButton extends ConsumerWidget {
  const _ShareMatchButton({required this.match});

  final FriendlyMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final when =
        '${formatDay(locale, parseApiDay(match.day))} · ${l10n.timeRange(formatTime(locale, match.startTime), formatTime(locale, match.endTime))}';
    final text = l10n.matchShareText(match.title, when, match.id);

    Future<void> toFriend() async {
      final picked = await showPersonPicker(context);
      if (picked == null) return;
      try {
        await ref.read(chatRepositoryProvider).send(ChatTarget.person(picked.person.userId), text);
        if (context.mounted) showSnack(context, l10n.sentToFriend);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    return PopupMenuButton<int>(
      icon: const Icon(Icons.share_outlined),
      tooltip: l10n.shareMatch,
      onSelected: (choice) => choice == 0 ? toFriend() : SharePlus.instance.share(ShareParams(text: text)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 0,
          child: ListTile(leading: const Icon(Icons.send_outlined), title: Text(l10n.shareToFriend)),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(leading: const Icon(Icons.ios_share), title: Text(l10n.shareOutside)),
        ),
      ],
    );
  }
}

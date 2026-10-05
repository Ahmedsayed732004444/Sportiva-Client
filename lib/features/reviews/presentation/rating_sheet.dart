import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/rating_input.dart';
import '../../../core/widgets/snack.dart';
import '../../social/data/social_models.dart';

typedef RatingSubmit = Future<void> Function(int rating, String? comment);

// Asks for stars and an optional comment, sends them with [submit], and says whether it went through.
Future<bool> showRatingSheet(
  BuildContext context, {
  required String title,
  required RatingSubmit submit,
  int initialRating = 0,
  String? initialComment,
}) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _RatingForm(title: title, submit: submit, initialRating: initialRating, initialComment: initialComment),
  );
  return sent ?? false;
}

class _RatingForm extends StatefulWidget {
  const _RatingForm({required this.title, required this.submit, required this.initialRating, this.initialComment});

  final String title;
  final RatingSubmit submit;
  final int initialRating;
  final String? initialComment;

  @override
  State<_RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends State<_RatingForm> {
  late final _comment = TextEditingController(text: widget.initialComment);
  late int _rating = widget.initialRating;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_rating == 0 || _busy) return;
    setState(() => _busy = true);

    try {
      await widget.submit(_rating, _comment.text.trim().isEmpty ? null : _comment.text.trim());
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showApiError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          RatingInput(value: _rating, onChanged: (value) => setState(() => _rating = value)),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: InputDecoration(hintText: l10n.commentOptional),
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(label: l10n.submitReview, isLoading: _busy, onPressed: _rating == 0 ? null : _send),
        ],
      ),
    );
  }
}

typedef PlayerRatingSubmit = Future<void> Function(String playerId, int rating, String? comment);

// A list of players: tapping one asks for his rating. Players already rated get a check mark.
Future<void> showPlayersRatingSheet(
  BuildContext context, {
  required List<Person> players,
  required PlayerRatingSubmit submit,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _PlayersList(players: players, submit: submit),
);

class _PlayersList extends StatefulWidget {
  const _PlayersList({required this.players, required this.submit});

  final List<Person> players;
  final PlayerRatingSubmit submit;

  @override
  State<_PlayersList> createState() => _PlayersListState();
}

class _PlayersListState extends State<_PlayersList> {
  final _done = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.tapToRate, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          const SizedBox(height: AppSpacing.xs),
          for (final player in widget.players)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  player.fullName.isEmpty ? '?' : player.fullName[0],
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
              title: Text(player.fullName),
              trailing: _done.contains(player.userId)
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : const Icon(Icons.star_border_rounded),
              onTap: _done.contains(player.userId)
                  ? null
                  : () async {
                      final sent = await showRatingSheet(
                        context,
                        title: player.fullName,
                        submit: (rating, comment) => widget.submit(player.userId, rating, comment),
                      );
                      if (sent && mounted) setState(() => _done.add(player.userId));
                    },
            ),
        ],
      ),
    );
  }
}

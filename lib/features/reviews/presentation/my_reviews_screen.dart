import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/snack.dart';
import '../application/review_controllers.dart';
import '../data/review_models.dart';
import '../data/review_repository.dart';
import 'rating_sheet.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.myReviews),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.black600,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: l10n.reviewsWritten),
              Tab(text: l10n.reviewsReceived),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PagedListView<MyReview>(
              state: writtenReviewsProvider,
              actions: writtenReviewsProvider.notifier,
              emptyMessage: l10n.noReviews,
              emptyIcon: Icons.star_border_rounded,
              itemBuilder: (context, review) => _ReviewTile(review: review, mine: true),
            ),
            PagedListView<MyReview>(
              state: receivedReviewsProvider,
              actions: receivedReviewsProvider.notifier,
              emptyMessage: l10n.noReviews,
              emptyIcon: Icons.star_border_rounded,
              itemBuilder: (context, review) => _ReviewTile(review: review, mine: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({required this.review, required this.mine});

  final MyReview review;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repository = ref.read(reviewRepositoryProvider);

    Future<void> edit() async {
      final sent = await showRatingSheet(
        context,
        title: review.subject,
        initialRating: review.rating,
        initialComment: review.comment,
        submit: (rating, comment) => repository.update(review.id, rating, comment),
      );
      if (sent) ref.invalidate(writtenReviewsProvider);
    }

    Future<void> remove() async {
      try {
        await repository.delete(review.id);
        ref.invalidate(writtenReviewsProvider);
        if (context.mounted) showSnack(context, l10n.reviewDeleted);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    return ListTile(
      title: Row(
        children: [
          RatingBadge(rating: review.rating.toDouble()),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              mine ? review.subject : review.reviewerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body1Semibold,
            ),
          ),
        ],
      ),
      subtitle: Text(
        [
          if (review.comment?.isNotEmpty ?? false) review.comment!,
          if (!review.isRevealed) l10n.reviewHiddenUntil,
          relativeTime(l10n, review.createdAt),
        ].join('\n'),
      ),
      isThreeLine: true,
      trailing: mine && review.canEdit
          ? PopupMenuButton<bool>(
              onSelected: (isEdit) => isEdit ? edit() : remove(),
              itemBuilder: (_) => [
                PopupMenuItem(value: true, child: Text(l10n.editPost)),
                PopupMenuItem(value: false, child: Text(l10n.deleteReview)),
              ],
            )
          : null,
    );
  }
}

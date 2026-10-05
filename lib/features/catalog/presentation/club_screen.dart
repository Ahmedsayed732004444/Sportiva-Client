import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/relative_time.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/state_views.dart';
import '../../home/presentation/widgets/court_card.dart';
import '../application/club_providers.dart';
import 'widgets/distance_label.dart';
import '../data/catalog_models.dart';

class ClubScreen extends ConsumerWidget {
  const ClubScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = ref.watch(clubProvider(clubId));

    return club.when(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(clubProvider(clubId)),
        ),
      ),
      data: (club) => _ClubBody(club: club),
    );
  }
}

class _ClubBody extends ConsumerWidget {
  const _ClubBody({required this.club});

  final ClubDetails club;

  Future<void> _openMap() async {
    final url = club.latitude != null && club.longitude != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=${club.latitude},${club.longitude}')
        : club.mapUrl != null
        ? Uri.tryParse(club.mapUrl!)
        : null;
    if (url != null) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final courts = ref.watch(clubCourtsProvider(club.id));
    final reviews = ref.watch(clubReviewsProvider(club.id));
    final place = [club.address, club.city].whereType<String>().where((s) => s.isNotEmpty).toSet().join(' · ');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(url: club.imageUrl, icon: Icons.storefront_outlined),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(club.name, style: AppTextStyles.header)),
                      StarRating(rating: club.averageRating, count: club.reviewsCount, size: 20),
                    ],
                  ),
                  DistanceLabel(latitude: club.latitude, longitude: club.longitude),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      for (final sport in club.sports.toSet())
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Chip(
                            avatar: Icon(sport.icon, size: 18, color: AppColors.primary),
                            label: Text(sport.label(l10n), style: AppTextStyles.caption),
                            backgroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.gray200),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: Text(place, style: AppTextStyles.body1),
                    trailing: TextButton(onPressed: _openMap, child: Text(l10n.openInMaps)),
                  ),
                  if (club.phone.isNotEmpty)
                    AppButton(
                      label: l10n.callClub,
                      icon: Icons.phone,
                      style: AppButtonStyle.outlined,
                      onPressed: () => launchUrl(Uri(scheme: 'tel', path: club.phone)),
                    ),
                  _WorkingHours(days: club.workingHours),
                  const SizedBox(height: AppSpacing.m),
                  Text(l10n.courts, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  courts.when(
                    loading: () => const SizedBox(height: 100, child: LoadingView()),
                    error: (error, _) => ErrorView(
                      error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
                      onRetry: () => ref.invalidate(clubCourtsProvider(club.id)),
                    ),
                    data: (items) => items.isEmpty
                        ? EmptyView(message: l10n.nothingHere)
                        : Column(
                            children: [
                              for (final court in items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                                  child: CourtCard(
                                    court: court,
                                    width: double.infinity,
                                    imageAspectRatio: 16 / 7,
                                    onTap: () => context.push('/court/${court.id}'),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(l10n.reviews, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  reviews.when(
                    loading: () => const SizedBox(height: 80, child: LoadingView()),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (items) => items.isEmpty
                        ? Text(l10n.noReviews, style: AppTextStyles.body2.copyWith(color: AppColors.black600))
                        : Column(children: [for (final review in items) _ReviewTile(review: review)]),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkingHours extends StatelessWidget {
  const _WorkingHours({required this.days});

  final List<WorkingDay> days;

  static const _order = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;

    String nameOf(String day) => DateFormat.EEEE(locale).format(DateTime(2024, 1, 7 + _order.indexOf(day)));

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: const Icon(Icons.schedule_outlined, color: AppColors.primary),
        title: Text(l10n.workingHours, style: AppTextStyles.body1),
        children: [
          for (final day in [
            ...days,
          ]..sort((a, b) => _order.indexOf(a.dayOfWeek).compareTo(_order.indexOf(b.dayOfWeek))))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(nameOf(day.dayOfWeek), style: AppTextStyles.body2),
                  const Spacer(),
                  Text(
                    day.isClosed
                        ? l10n.closed
                        : l10n.timeRange(formatTime(locale, day.opensAt), formatTime(locale, day.closesAt)),
                    style: AppTextStyles.body2.copyWith(color: day.isClosed ? AppColors.error : AppColors.black),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(review.reviewerName, style: AppTextStyles.body1Semibold)),
              RatingBadge(rating: review.rating.toDouble()),
              const SizedBox(width: AppSpacing.xs),
              Text(
                relativeTime(context.l10n, review.createdAt),
                style: AppTextStyles.small.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
          if (review.comment?.isNotEmpty ?? false)
            Text(review.comment!, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
        ],
      ),
    );
  }
}

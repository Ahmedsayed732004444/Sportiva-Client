import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../application/home_controller.dart';
import 'widgets/club_card.dart';
import 'widgets/court_card.dart';
import 'widgets/section_header.dart';
import 'widgets/sports_row.dart';

// Top: the sports. Under them the nearest courts of the picked sport. Then the best rated clubs.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref.watch(authControllerProvider).valueOrNull?.firstName ?? '';
    final clubs = ref.watch(topClubsProvider);
    final clubsController = ref.read(topClubsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helloUser(name), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        actions: const [NotificationBell()],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(locationProvider.notifier).refreshPosition();
          ref.invalidate(nearestCourtsProvider);
          await clubsController.refresh();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.extentAfter < 400) clubsController.loadMore();
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xs)),
              const SliverToBoxAdapter(child: SportsRow()),
              const SliverToBoxAdapter(child: _NearestCourts()),
              const SliverToBoxAdapter(child: _TournamentsEntry()),
              SliverToBoxAdapter(child: SectionHeader(l10n.topRatedClubs)),
              if (clubs.isFirstLoad)
                const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.all(AppSpacing.l), child: LoadingView()),
                )
              else if (clubs.error != null && clubs.items.isEmpty)
                SliverToBoxAdapter(
                  child: ErrorView(error: clubs.error!, onRetry: clubsController.loadMore),
                )
              else if (clubs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: EmptyView(message: l10n.noClubsYet),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.l,
                  ),
                  sliver: SliverList.separated(
                    itemCount: clubs.items.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      if (index < clubs.items.length) {
                        return ClubCard(
                          club: clubs.items[index],
                          onTap: () => context.push('/club/${clubs.items[index].id}'),
                        );
                      }
                      if (clubs.error != null) return ErrorView(error: clubs.error!, onRetry: clubsController.loadMore);
                      return clubs.hasMore
                          ? const Padding(padding: EdgeInsets.all(AppSpacing.s), child: LoadingView())
                          : const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TournamentsEntry extends StatelessWidget {
  const _TournamentsEntry();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.m, AppSpacing.screenPadding, 0),
      child: AppCard(
        onTap: () => context.push('/tournaments'),
        child: ListTile(
          leading: const Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 32),
          title: Text(l10n.tournaments, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text(l10n.tournamentsSubtitle, style: AppTextStyles.body2),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _NearestCourts extends ConsumerWidget {
  const _NearestCourts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sport = ref.watch(selectedSportProvider);
    if (sport == null) return const SizedBox.shrink();

    final hasPosition = ref.watch(locationProvider).valueOrNull?.hasPosition ?? false;
    final courts = ref.watch(nearestCourtsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          hasPosition ? '${l10n.courtsNearYou} · ${sport.label(l10n)}' : l10n.courtsOfSport(sport.label(l10n)),
        ),
        courts.when(
          loading: () => const SizedBox(height: 120, child: LoadingView()),
          error: (error, _) => SizedBox(
            height: 160,
            child: ErrorView(
              error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
              onRetry: () => ref.invalidate(nearestCourtsProvider),
            ),
          ),
          data: (items) => items.isEmpty
              ? SizedBox(
                  height: 140,
                  child: EmptyView(message: l10n.noCourtsForSport, icon: sport.icon),
                )
              : SizedBox(
                  height: 268,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
                    itemBuilder: (context, index) =>
                        CourtCard(court: items[index], onTap: () => context.push('/court/${items[index].id}')),
                  ),
                ),
        ),
      ],
    );
  }
}

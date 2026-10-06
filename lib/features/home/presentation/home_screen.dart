import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/location/location_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../../settings/application/account_providers.dart';
import '../application/home_controller.dart';
import 'widgets/club_card.dart';
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
              const SliverToBoxAdapter(child: _SearchBar()),
              const SliverToBoxAdapter(child: SportsRow()),
              const SliverToBoxAdapter(child: _TournamentsEntry()),
              const SliverToBoxAdapter(child: _BecomeOwnerEntry()),
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
          leading: Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 32),
          title: Text(l10n.tournaments, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text(l10n.tournamentsSubtitle, style: AppTextStyles.body2),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

// A player can ask to become a club owner; the entry goes away once they are one.
class _BecomeOwnerEntry extends ConsumerWidget {
  const _BecomeOwnerEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(managesClubProvider)) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.s, AppSpacing.screenPadding, 0),
      child: AppCard(
        onTap: () => context.push('/membership'),
        child: ListTile(
          leading: Icon(Icons.add_business_outlined, color: AppColors.primary, size: 32),
          title: Text(l10n.becomeOwner, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text(
            l10n.membershipIntro,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body2,
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

// The way into the search: looks like a field, opens the search page.
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.s),
      child: AppCard(
        onTap: () => context.push('/find'),
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(l10n.searchHint, style: AppTextStyles.body1.copyWith(color: AppColors.black600)),
              ),
              Icon(Icons.tune, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

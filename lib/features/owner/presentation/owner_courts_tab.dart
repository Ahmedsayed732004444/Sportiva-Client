import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../application/owner_controllers.dart';
import '../data/owner_court_models.dart';
import '../data/owner_court_repository.dart';

enum _CourtAction { edit, prices, slots, photos, delete }

class OwnerCourtsTab extends ConsumerWidget {
  const OwnerCourtsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final courts = ref.watch(ownerCourtsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/courts/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onBrand,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCourt),
      ),
      body: courts.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(ownerCourtsProvider),
        ),
        data: (courts) => courts.isEmpty
            ? EmptyView(message: l10n.noCourts, icon: Icons.sports_tennis_outlined)
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(ownerCourtsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  itemCount: courts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
                  itemBuilder: (context, index) => _CourtCard(court: courts[index]),
                ),
              ),
      ),
    );
  }
}

class _CourtCard extends ConsumerWidget {
  const _CourtCard({required this.court});

  final OwnerCourt court;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repository = ref.read(ownerCourtRepositoryProvider);

    Future<void> run(Future<void> Function() action, {String? done}) async {
      try {
        await action();
        ref.invalidate(ownerCourtsProvider);
        if (context.mounted && done != null) showSnack(context, done);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    }

    Future<void> onAction(_CourtAction action) async {
      switch (action) {
        case _CourtAction.edit:
          await context.push('/owner/courts/${court.id}/edit');
        case _CourtAction.prices:
          await context.push('/owner/courts/${court.id}/prices');
        case _CourtAction.slots:
          await context.push('/owner/courts/${court.id}/slots');
        case _CourtAction.photos:
          await context.push('/owner/courts/${court.id}/photos');
          ref.invalidate(ownerCourtsProvider);
        case _CourtAction.delete:
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deleteCourt),
              content: Text(l10n.deleteCourtBody),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.deleteCourt, style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed == true) await run(() => repository.delete(court.id), done: l10n.courtDeleted);
      }
    }

    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: AppNetworkImage(url: court.coverUrl, icon: court.sport.icon),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(court.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body1Semibold),
                  Text(
                    '${court.sport.label(l10n)} · ${formatPricePerHour(l10n, court.pricePiasters)}',
                    style: AppTextStyles.body2,
                  ),
                  Row(
                    children: [
                      Text(l10n.courtActive, style: AppTextStyles.caption),
                      const SizedBox(width: 4),
                      Switch(
                        value: court.isActive,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) => run(() => repository.toggle(court.id)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<_CourtAction>(
            onSelected: onAction,
            itemBuilder: (_) => [
              PopupMenuItem(value: _CourtAction.edit, child: Text(l10n.editCourt)),
              PopupMenuItem(value: _CourtAction.prices, child: Text(l10n.priceRules)),
              PopupMenuItem(value: _CourtAction.slots, child: Text(l10n.slotsAndClosing)),
              PopupMenuItem(value: _CourtAction.photos, child: Text(l10n.courtPhotosMenu)),
              PopupMenuItem(value: _CourtAction.delete, child: Text(l10n.deleteCourt)),
            ],
          ),
        ],
      ),
    );
  }
}

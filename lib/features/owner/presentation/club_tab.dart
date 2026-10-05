import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/snack.dart';
import '../../../core/widgets/state_views.dart';
import '../../payments/data/payment_models.dart';
import '../../payments/presentation/pay_flow.dart';
import '../application/owner_controllers.dart';
import '../data/owner_club_models.dart';
import '../data/owner_club_repository.dart';

class ClubTab extends ConsumerWidget {
  const ClubTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final club = ref.watch(ownerClubProvider);

    return club.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
        onRetry: () => ref.invalidate(ownerClubProvider),
      ),
      data: (club) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(ownerClubProvider),
        child: ListView(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: AppNetworkImage(url: club.coverUrl, icon: Icons.landscape_outlined),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name, style: AppTextStyles.header),
                  Row(
                    children: [
                      RatingBadge(rating: club.rating, count: club.reviewsCount),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            if (club.isOwner) ...[
              SwitchListTile(
                title: Text(l10n.clubOpen),
                value: club.isActive,
                activeTrackColor: AppColors.primary,
                onChanged: (_) async {
                  try {
                    await ref.read(ownerClubRepositoryProvider).toggleStatus();
                    ref.invalidate(ownerClubProvider);
                  } on ApiException catch (e) {
                    if (context.mounted) showApiError(context, e);
                  }
                },
              ),
              _SubscriptionCard(club: club),
            ],
            if (club.isOwner) ...[
              _tile(context, Icons.edit_outlined, l10n.editClubInfo, '/owner/club/edit'),
              _tile(context, Icons.schedule_outlined, l10n.workingHours, '/owner/club/hours'),
              _tile(context, Icons.photo_library_outlined, l10n.clubPhotos, '/owner/club/photos'),
              _tile(context, Icons.bar_chart, l10n.reports, '/owner/reports'),
              _PhotoTile(icon: Icons.image_outlined, label: l10n.changeLogo, pick: (repo, path) => repo.setLogo(path)),
              _PhotoTile(
                icon: Icons.panorama_outlined,
                label: l10n.changeCover,
                pick: (repo, path) => repo.setCover(path),
              ),
              _tile(context, Icons.groups_outlined, l10n.staff, '/owner/staff'),
            ],
            _tile(context, Icons.history, l10n.activityLog, '/owner/activity'),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String route) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title, style: AppTextStyles.body1),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(route),
  );
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({required this.icon, required this.label, required this.pick});

  final IconData icon;
  final String label;
  final Future<void> Function(OwnerClubRepository repository, String path) pick;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(label, style: AppTextStyles.body1),
    onTap: () async {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 2000);
      if (picked == null) return;
      try {
        await pick(ref.read(ownerClubRepositoryProvider), picked.path);
        ref.invalidate(ownerClubProvider);
        if (context.mounted) showSnack(context, context.l10n.photoUpdated);
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
      }
    },
  );
}

class _SubscriptionCard extends ConsumerWidget {
  const _SubscriptionCard({required this.club});

  final OwnerClub club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final subscription = club.subscription;
    final state = subscription?.state ?? SubscriptionState.none;
    final repository = ref.read(ownerClubRepositoryProvider);

    Future<void> pay(Future<PaymentSession> Function(PayMethod method) start) => startPayment(context, ref, start);

    Future<void> choosePlan() async {
      final List<Plan> plans;
      try {
        plans = await repository.plans();
      } on ApiException catch (e) {
        if (context.mounted) showApiError(context, e);
        return;
      }
      if (!context.mounted) return;

      final plan = await showModalBottomSheet<Plan>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.choosePlan, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              for (final plan in plans)
                ListTile(
                  title: Text(plan.name),
                  subtitle: Text(l10n.planDetails(formatPounds(plan.pricePiasters), plan.maxCourts, plan.durationDays)),
                  onTap: () => Navigator.pop(context, plan),
                ),
            ],
          ),
        ),
      );
      if (plan != null) await pay((method) => repository.subscribe(plan.id, method));
    }

    final label = switch (state) {
      SubscriptionState.none => l10n.subNone,
      SubscriptionState.active => l10n.subActive,
      SubscriptionState.gracePeriod => l10n.subGrace,
      SubscriptionState.expired => l10n.subExpired,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.xs),
      elevation: 0,
      color: state == SubscriptionState.active ? AppColors.primary.withValues(alpha: 0.08) : AppColors.gray200,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.subscription}: $label', style: AppTextStyles.body1Semibold),
            if (subscription?.planName != null)
              Text('${l10n.subPlan}: ${subscription!.planName}', style: AppTextStyles.body2),
            if (subscription?.endsAt != null)
              Text(
                '${l10n.subEnds}: ${formatLongDay(locale, subscription!.endsAt!.toLocal())}',
                style: AppTextStyles.body2,
              ),
            if (subscription?.maxCourts != null)
              Text(l10n.subCourts(subscription!.courtsCount, subscription.maxCourts!), style: AppTextStyles.body2),
            const SizedBox(height: AppSpacing.xs),
            if (state == SubscriptionState.none)
              AppButton(label: l10n.subscribeNow, onPressed: choosePlan)
            else if (state != SubscriptionState.active || (subscription?.renewalRequired ?? false))
              AppButton(label: l10n.renewNow, onPressed: () => pay(repository.renew)),
          ],
        ),
      ),
    );
  }
}

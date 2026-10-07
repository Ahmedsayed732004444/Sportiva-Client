import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../application/social_controllers.dart';
import '../../data/social_models.dart';
import '../../data/social_repository.dart';

// A row of people the user may want to follow, each with why (people you follow follow them, same governorate).
class SuggestedPeople extends ConsumerWidget {
  const SuggestedPeople({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hidden = ref.watch(hiddenSuggestionsProvider);
    final people = (ref.watch(suggestionsProvider).valueOrNull ?? const <SuggestedPerson>[])
        .where((s) => !hidden.contains(s.person.userId))
        .toList();
    if (people.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
            child: Text(l10n.suggestedPeople, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: people.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, index) => _PersonCard(suggestion: people[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends ConsumerStatefulWidget {
  const _PersonCard({required this.suggestion});

  final SuggestedPerson suggestion;

  @override
  ConsumerState<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends ConsumerState<_PersonCard> {
  bool _busy = false;

  Future<void> _follow() async {
    setState(() => _busy = true);
    try {
      await ref.read(socialRepositoryProvider).toggleFollow(widget.suggestion.person.userId);
      final hidden = ref.read(hiddenSuggestionsProvider.notifier);
      hidden.state = {...hidden.state, widget.suggestion.person.userId};
    } on Object {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = widget.suggestion;
    final why = s.mutualFollowers > 0
        ? l10n.followedByMutual(s.mutualFollowers)
        : s.sameGovernorate
        ? l10n.sameGovernorateHint
        : l10n.popularHint(s.followersCount);

    return SizedBox(
      width: 148,
      child: AppCard(
        onTap: () => context.push('/user/${s.person.userId}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            children: [
              UserAvatar(name: s.person.fullName, url: s.person.avatarUrl, radius: 32),
              const SizedBox(height: AppSpacing.xs),
              Text(s.person.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body1Semibold),
              Text(
                why,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: AppColors.black600),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _follow,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    l10n.follow,
                    style: AppTextStyles.body2.copyWith(color: AppColors.onBrand, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

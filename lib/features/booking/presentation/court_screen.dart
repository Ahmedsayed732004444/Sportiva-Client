import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/localization/price_format.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/choice_chips.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/submit_mixin.dart';
import '../../../core/widgets/stepper_field.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/presentation/widgets/distance_label.dart';
import '../../matches/data/match_repository.dart';
import '../application/court_booking_controller.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';
import '../domain/slot_planner.dart';
import 'booking_labels.dart';

class CourtScreen extends ConsumerWidget {
  const CourtScreen({super.key, required this.courtId, this.matchMode = false});

  final String courtId;
  // Booking this court to play a match with others: the booking opens as a match.
  final bool matchMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final court = ref.watch(courtProvider(courtId));

    return court.when(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
          onRetry: () => ref.invalidate(courtProvider(courtId)),
        ),
      ),
      data: (court) => _CourtBody(court: court, matchMode: matchMode),
    );
  }
}

class _CourtBody extends ConsumerStatefulWidget {
  const _CourtBody({required this.court, required this.matchMode});

  final CourtDetails court;
  final bool matchMode;

  @override
  ConsumerState<_CourtBody> createState() => _CourtBodyState();
}

class _CourtBodyState extends ConsumerState<_CourtBody> with SubmitMixin {
  CourtDetails get court => widget.court;

  Future<void> _book(CourtSelection selection, BookableStart start) async {
    final confirmed = await showModalBottomSheet<_Confirmed>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ConfirmSheet(court: court, selection: selection, start: start, matchMode: widget.matchMode),
    );
    if (confirmed == null || !mounted) return;

    String? target;
    final done = await submit(() async {
      if (widget.matchMode) {
        final match = await ref
            .read(matchRepositoryProvider)
            .createOnCourt(
              courtId: court.id,
              day: selection.day,
              startTime: start.startTime,
              durationMinutes: selection.durationMinutes,
              part: selection.part,
              playFormat: selection.playFormat,
              playersNeeded: confirmed.players,
              note: confirmed.note,
            );
        target = '/match/${match.id}';
      } else {
        final booking = await ref
            .read(bookingRepositoryProvider)
            .create(
              courtId: court.id,
              day: selection.day,
              startTime: start.startTime,
              durationMinutes: selection.durationMinutes,
              part: selection.part,
              playFormat: selection.playFormat,
            );
        target = '/booking/${booking.id}';
      }
    });

    if (!mounted) return;
    if (done && target != null) {
      final l10n = context.l10n;
      showMessage(
        widget.matchMode
            ? l10n.matchStartedOnCourt
            : (court.isAutomatic ? l10n.bookingConfirmed : l10n.bookingRequested),
      );
      context.pushReplacement(target!);
    } else {
      // Probably taken a moment ago: show what is free now.
      ref.invalidate(availabilityProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectionProvider = courtSelectionProvider(court);
    final selection = ref.watch(selectionProvider);
    final controller = ref.read(selectionProvider.notifier);
    final locale = Localizations.localeOf(context).languageCode;

    final availability = ref.watch(availabilityProvider((courtId: court.id, day: selection.day)));
    final starts = availability.valueOrNull == null
        ? const <BookableStart>[]
        : SlotPlanner.starts(availability.value!, durationMinutes: selection.durationMinutes, part: selection.part);
    final chosen = starts.where((s) => s.startTime == selection.startTime).firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(url: court.imageUrl, icon: court.sport.icon),
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
                      Expanded(child: Text(court.name, style: AppTextStyles.header)),
                      StarRating(rating: court.averageRating, count: court.reviewsCount, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  DistanceLabel(latitude: court.club.latitude, longitude: court.club.longitude),
                  Text(
                    '${court.club.name} · ${court.sport.label(l10n)}',
                    style: AppTextStyles.body1.copyWith(color: AppColors.black600),
                  ),
                  if (court.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(court.description!, style: AppTextStyles.paragraph),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    formatPricePerHour(l10n, court.pricePerHourPiasters),
                    style: AppTextStyles.body1Semibold.copyWith(color: AppColors.primary),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => context.push('/court/${court.id}/recurring'),
                      icon: const Icon(Icons.repeat),
                      label: Text(l10n.recurringBooking),
                    ),
                  ),
                  _Section(
                    title: l10n.chooseDay,
                    child: _DayStrip(selected: selection.day, locale: locale, onPicked: controller.pickDay),
                  ),
                  _Section(
                    title: l10n.duration,
                    child: ChoiceChips<int>(
                      options: court.allowedDurations,
                      selected: selection.durationMinutes,
                      labelOf: (m) => l10n.minutesLabel(m),
                      onSelected: controller.pickDuration,
                    ),
                  ),
                  if (court.allowsHalfCourt)
                    _Section(
                      title: l10n.courtPart,
                      child: ChoiceChips<CourtPart>(
                        options: CourtPart.values,
                        selected: selection.part,
                        labelOf: (p) => p.label(l10n),
                        onSelected: controller.pickPart,
                      ),
                    ),
                  if (PlayFormat.appliesTo(court.sport))
                    _Section(
                      title: l10n.playFormat,
                      child: ChoiceChips<PlayFormat>(
                        options: PlayFormat.values,
                        selected: selection.playFormat,
                        labelOf: (f) => f.label(l10n),
                        onSelected: controller.pickFormat,
                      ),
                    ),
                  _Section(
                    title: l10n.chooseTime,
                    child: availability.when(
                      loading: () => const SizedBox(height: 80, child: LoadingView()),
                      error: (error, _) => ErrorView(
                        error: error is ApiException ? error : const ApiException(kind: ApiErrorKind.unknown),
                        onRetry: () => ref.invalidate(availabilityProvider),
                      ),
                      data: (_) => starts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                              child: Text(
                                l10n.noTimesAvailable,
                                style: AppTextStyles.body2.copyWith(color: AppColors.black600),
                              ),
                            )
                          : ChoiceChips<BookableStart>(
                              options: starts,
                              selected: chosen,
                              labelOf: (s) => formatTime(locale, s.startTime),
                              onSelected: (s) => controller.pickStart(s.startTime),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.white, boxShadow: AppShadows.drop),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Row(
              children: [
                if (chosen != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSpacing.s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.total, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
                        Text(
                          l10n.priceTotal(formatPounds(chosen.pricePiasters)),
                          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: AppButton(
                    label: widget.matchMode ? l10n.openMatchNow : l10n.bookNow,
                    isLoading: isSubmitting,
                    onPressed: chosen == null || !court.canBook ? null : () => _book(selection, chosen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.m),
        Text(title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.selected, required this.locale, required this.onPicked});

  final DateTime selected;
  final String locale;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final first = today();

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bookingDaysAhead,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final day = first.add(Duration(days: index));
          final isSelected = day == selected;

          return InkWell(
            onTap: () => onPicked(day),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.gray400),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDay(locale, day).split(' ').first,
                    style: AppTextStyles.caption.copyWith(color: isSelected ? AppColors.white : AppColors.black600),
                  ),
                  Text(
                    '${day.day}',
                    style: AppTextStyles.title.copyWith(
                      color: isSelected ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// What the player decided in the summary sheet: how many players to find when it is a match, and a note for them.
class _Confirmed {
  const _Confirmed({this.players = 0, this.note});

  final int players;
  final String? note;
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.court, required this.selection, required this.start, required this.matchMode});

  final CourtDetails court;
  final CourtSelection selection;
  final BookableStart start;
  final bool matchMode;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  final _note = TextEditingController();
  int _players = 3;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final court = widget.court;
    final selection = widget.selection;
    final start = widget.start;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.black600)),
          const Spacer(),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: AppTextStyles.body1Semibold),
          ),
        ],
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.bookingSummary, style: AppTextStyles.header),
            const SizedBox(height: AppSpacing.s),
            row(l10n.court, '${court.club.name} - ${court.name}'),
            row(l10n.dateLabel, formatLongDay(locale, selection.day)),
            row(l10n.timeLabel, l10n.timeRange(formatTime(locale, start.startTime), formatTime(locale, start.endTime))),
            row(l10n.duration, l10n.minutesLabel(selection.durationMinutes)),
            if (court.allowsHalfCourt) row(l10n.courtPart, selection.part.label(l10n)),
            const Divider(),
            row(l10n.total, l10n.priceTotal(formatPounds(start.pricePiasters))),
            if (!court.isAutomatic)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(l10n.waitingForClub, style: AppTextStyles.body2.copyWith(color: AppColors.primaryMid)),
              ),
            if (widget.matchMode) ...[
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Expanded(child: Text(l10n.playersNeeded, style: AppTextStyles.title)),
                  StepperField(value: _players, onChanged: (value) => setState(() => _players = value)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _note,
                decoration: InputDecoration(hintText: l10n.enterNote),
              ),
              const SizedBox(height: 4),
              Text(l10n.openAsMatchHint, style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
            ],
            const SizedBox(height: AppSpacing.m),
            AppButton(
              label: widget.matchMode ? l10n.openMatchNow : l10n.confirmBooking,
              onPressed: () => Navigator.of(context).pop(
                _Confirmed(
                  players: widget.matchMode ? _players : 0,
                  note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(label: l10n.cancel, style: AppButtonStyle.outlined, onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

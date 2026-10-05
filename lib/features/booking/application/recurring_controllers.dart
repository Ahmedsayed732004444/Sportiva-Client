import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../data/recurring_models.dart';
import '../data/recurring_repository.dart';

mixin _FollowsRecurring on PagedController<RecurringBooking> {
  void followChanges() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.recurringBookingChanged || event.name == RealtimeEvents.reconnected) refresh();
    });
    ref.onDispose(subscription.cancel);
  }
}

class MyRecurringController extends PagedController<RecurringBooking> with _FollowsRecurring {
  @override
  PagedState<RecurringBooking> build() {
    followChanges();
    return super.build();
  }

  @override
  Future<PagedResult<RecurringBooking>> fetch(int page) => ref.read(recurringRepositoryProvider).mine(page);
}

class ClubRecurringController extends PagedController<RecurringBooking> with _FollowsRecurring {
  @override
  PagedState<RecurringBooking> build() {
    followChanges();
    return super.build();
  }

  @override
  Future<PagedResult<RecurringBooking>> fetch(int page) => ref.read(recurringRepositoryProvider).clubList(page);
}

final myRecurringProvider = AutoDisposeNotifierProvider<MyRecurringController, PagedState<RecurringBooking>>(
  MyRecurringController.new,
);
final clubRecurringProvider = AutoDisposeNotifierProvider<ClubRecurringController, PagedState<RecurringBooking>>(
  ClubRecurringController.new,
);

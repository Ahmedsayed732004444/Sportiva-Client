import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../booking/data/booking_models.dart';
import '../data/owner_booking_repository.dart';
import '../data/owner_club_models.dart';
import '../data/owner_club_repository.dart';
import '../data/owner_court_models.dart';
import '../data/owner_court_repository.dart';

abstract class OwnerBookingsController extends PagedController<Booking> {
  OwnerBookingTab get tab;

  @override
  PagedState<Booking> build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.bookingChanged || event.name == RealtimeEvents.reconnected) refresh();
    });
    ref.onDispose(subscription.cancel);
    return super.build();
  }

  @override
  Future<PagedResult<Booking>> fetch(int page) => ref.read(ownerBookingRepositoryProvider).list(tab, page: page);
}

class PendingOwnerBookings extends OwnerBookingsController {
  @override
  OwnerBookingTab get tab => OwnerBookingTab.pending;
}

class UpcomingOwnerBookings extends OwnerBookingsController {
  @override
  OwnerBookingTab get tab => OwnerBookingTab.upcoming;
}

class PastOwnerBookings extends OwnerBookingsController {
  @override
  OwnerBookingTab get tab => OwnerBookingTab.past;
}

final pendingOwnerBookingsProvider = AutoDisposeNotifierProvider<PendingOwnerBookings, PagedState<Booking>>(
  PendingOwnerBookings.new,
);
final upcomingOwnerBookingsProvider = AutoDisposeNotifierProvider<UpcomingOwnerBookings, PagedState<Booking>>(
  UpcomingOwnerBookings.new,
);
final pastOwnerBookingsProvider = AutoDisposeNotifierProvider<PastOwnerBookings, PagedState<Booking>>(
  PastOwnerBookings.new,
);

final ownerCourtsProvider = FutureProvider.autoDispose<List<OwnerCourt>>((ref) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    if (event.name == RealtimeEvents.clubChanged || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);
  return ref.read(ownerCourtRepositoryProvider).list();
});

final ownerClubProvider = FutureProvider.autoDispose<OwnerClub>((ref) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    const names = {RealtimeEvents.clubChanged, RealtimeEvents.paymentChanged, RealtimeEvents.reconnected};
    if (names.contains(event.name)) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);
  return ref.read(ownerClubRepositoryProvider).club();
});

final staffProvider = FutureProvider.autoDispose<List<StaffMember>>(
  (ref) => ref.read(ownerClubRepositoryProvider).staff(),
);

class ActivityController extends PagedController<ActivityEntry> {
  @override
  Future<PagedResult<ActivityEntry>> fetch(int page) => ref.read(ownerClubRepositoryProvider).activity(page);
}

final activityProvider = AutoDisposeNotifierProvider<ActivityController, PagedState<ActivityEntry>>(
  ActivityController.new,
);

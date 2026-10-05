import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../../../core/realtime/realtime_service.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';

// "My bookings": a list of the ones still to come and a list of the ones that ended. Both follow BookingChanged live.
abstract class BookingsController extends PagedController<Booking> {
  bool get upcoming;

  @override
  PagedState<Booking> build() {
    final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
      if (event.name == RealtimeEvents.bookingChanged || event.name == RealtimeEvents.reconnected) refresh();
    });
    ref.onDispose(subscription.cancel);

    return super.build();
  }

  @override
  Future<PagedResult<Booking>> fetch(int page) =>
      ref.read(bookingRepositoryProvider).mine(upcoming: upcoming, page: page);
}

class UpcomingBookingsController extends BookingsController {
  @override
  bool get upcoming => true;
}

class PastBookingsController extends BookingsController {
  @override
  bool get upcoming => false;
}

final upcomingBookingsProvider = AutoDisposeNotifierProvider<UpcomingBookingsController, PagedState<Booking>>(
  UpcomingBookingsController.new,
);
final pastBookingsProvider = AutoDisposeNotifierProvider<PastBookingsController, PagedState<Booking>>(
  PastBookingsController.new,
);

final bookingProvider = FutureProvider.autoDispose.family<Booking, String>((ref, id) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    final sameBooking = event.name == RealtimeEvents.bookingChanged && event.json?['bookingId'] == id;
    if (sameBooking || event.name == RealtimeEvents.reconnected) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  return ref.read(bookingRepositoryProvider).get(id);
});

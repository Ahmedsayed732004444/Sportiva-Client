import '../data/app_notification.dart';

// The screen a notification is about, or null when there is nothing more specific than the notifications list.
// Notifications carry what they concern (entityType / entityId); the type says who they are for.
String? notificationRoute(AppNotification notification) {
  final id = notification.entityId;
  final type = notification.type;

  switch (notification.entityType) {
    case 'Booking':
      if (id == null) return null;
      // The club is told about a request; the player about its answer.
      return type == 'BookingRequested' ? '/owner' : '/booking/$id';
    case 'RecurringBooking':
      return type == 'RecurringBookingRequested' ? '/owner' : '/bookings/recurring';
    case 'FriendlyMatch':
      return id == null ? null : '/match/$id';
    case 'Post':
      return id == null ? null : '/post/$id';
    case 'ApplicationUser':
      if (id == null) return null;
      return type == 'NewMessage' ? '/chat/$id' : '/user/$id';
    case 'MembershipRequest':
      return '/membership';
    case 'Tournament':
      return id == null ? null : '/tournament/$id';
    case 'TournamentTeam':
      if (id == null) return null;
      return type == 'TournamentInvitation' ? '/tournaments/mine' : '/team/$id';
    case 'Club':
      return type == 'StaffAdded' ? '/owner' : (id == null ? null : '/club/$id');
    case 'ClubPayout':
      return '/owner';
  }

  return switch (type) {
    'SubscriptionExpiring' || 'SubscriptionGraceStarted' || 'SubscriptionStopped' => '/owner',
    'TournamentQualified' || 'TournamentEliminated' || 'PaymentFailed' || 'PaymentSucceeded' => '/tournaments/mine',
    _ => null,
  };
}

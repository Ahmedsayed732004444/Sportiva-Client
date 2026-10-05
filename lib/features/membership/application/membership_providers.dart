import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/realtime/realtime_service.dart';
import '../../auth/application/auth_controller.dart';
import '../../settings/application/account_providers.dart';
import '../data/membership_models.dart';
import '../data/membership_repository.dart';

// The user's club-owner request. When the team approves it, the account gets the Owner role: the session is renewed
// (the roles live in the token) and the club section appears without signing in again.
final membershipProvider = FutureProvider.autoDispose<MembershipRequest?>((ref) {
  final subscription = ref.read(realtimeServiceProvider).events.listen((event) {
    if (event.name == RealtimeEvents.membershipChanged || event.name == RealtimeEvents.reconnected) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(subscription.cancel);

  return ref.read(membershipRepositoryProvider).mine().then((request) async {
    if (request?.status == MembershipStatus.approved &&
        !(ref.read(accountProvider).valueOrNull?.managesClub ?? false)) {
      await ref.read(authControllerProvider.notifier).refreshSession();
      ref.invalidate(accountProvider);
    }
    return request;
  });
});

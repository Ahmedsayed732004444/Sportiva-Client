import '../../features/social/presentation/saved_posts_screen.dart';
import '../../features/catalog/presentation/search_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/auth_route_args.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/booking/presentation/booking_details_screen.dart';
import '../../features/booking/presentation/bookings_screen.dart';
import '../../features/booking/presentation/court_screen.dart';
import '../../features/catalog/data/sport_type.dart';
import '../../features/catalog/presentation/club_screen.dart';
import '../../features/catalog/presentation/courts_screen.dart';
import '../../features/booking/presentation/recurring_screens.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/location/location_gate_screen.dart';
import '../../features/matches/presentation/create_match_screen.dart';
import '../../features/matches/presentation/match_chat_screen.dart';
import '../../features/matches/presentation/match_details_screen.dart';
import '../../features/matches/presentation/matches_screen.dart';
import '../../features/membership/presentation/membership_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/tournaments/presentation/my_teams_screen.dart';
import '../../features/tournaments/presentation/team_screen.dart';
import '../../features/tournaments/presentation/tournament_details_screen.dart';
import '../../features/tournaments/presentation/tournaments_screen.dart';
import '../../features/owner/presentation/activity_screen.dart';
import '../../features/owner/presentation/club_edit_screen.dart';
import '../../features/owner/presentation/staff_screen.dart';
import '../../features/owner/presentation/working_hours_screen.dart';
import '../../features/owner/presentation/owner_tournament_screen.dart';
import '../../features/owner/presentation/tournament_form_screen.dart';
import '../../features/owner/presentation/photos_screen.dart';
import '../../features/owner/presentation/reports_screen.dart';
import '../../features/owner/presentation/court_form_screen.dart';
import '../../features/owner/presentation/court_slots_screen.dart';
import '../../features/owner/presentation/manual_booking_screen.dart';
import '../../features/owner/presentation/owner_screen.dart';
import '../../features/owner/presentation/price_rules_screen.dart';
import '../../features/reviews/presentation/my_reviews_screen.dart';
import '../../features/settings/presentation/change_password_screen.dart';
import '../../features/settings/presentation/notification_preferences_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/social/presentation/conversations_screen.dart';
import '../../features/social/presentation/create_post_screen.dart';
import '../../features/social/presentation/direct_chat_screen.dart';
import '../../features/social/presentation/edit_profile_screen.dart';
import '../../features/social/presentation/follow_list_screen.dart';
import '../../features/social/presentation/post_details_screen.dart';
import '../../features/social/presentation/search_screen.dart';
import '../../features/social/presentation/social_screen.dart';
import '../../features/social/presentation/user_profile_screen.dart';

import '../../features/profile/profile_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../location/location_controller.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-runs the redirect whenever the user signs in or out.
  final authChanged = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => authChanged.value++);
  ref.listen(locationProvider, (_, _) => authChanged.value++);
  ref.onDispose(authChanged.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authChanged,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) return location == AppRoutes.splash ? null : AppRoutes.splash;

      if (auth.valueOrNull == null) return AppRoutes.authPages.contains(location) ? null : AppRoutes.login;

      // Signed in: the location question comes before the home.
      final place = ref.read(locationProvider);
      if (place.isLoading) return location == AppRoutes.splash ? null : AppRoutes.splash;
      if (!(place.valueOrNull?.decided ?? true)) return location == AppRoutes.location ? null : AppRoutes.location;

      return location == AppRoutes.splash || location == AppRoutes.location || AppRoutes.authPages.contains(location)
          ? AppRoutes.home
          : null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.location, builder: (_, _) => const LocationGateScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(
        path: AppRoutes.otp,
        redirect: (_, state) => state.extra is OtpArgs ? null : AppRoutes.login,
        builder: (_, state) => OtpScreen(args: state.extra! as OtpArgs),
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        redirect: (_, state) => state.extra is NewPasswordArgs ? null : AppRoutes.login,
        builder: (_, state) => NewPasswordScreen(args: state.extra! as NewPasswordArgs),
      ),
      GoRoute(
        path: '/club/:id',
        builder: (_, state) => ClubScreen(clubId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/court/:id',
        builder: (_, state) =>
            CourtScreen(courtId: state.pathParameters['id']!, matchMode: state.uri.queryParameters['match'] == '1'),
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (_, state) => BookingDetailsScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/find',
        builder: (_, state) => CatalogSearchScreen(
          sport: state.uri.queryParameters['sport'] == null
              ? null
              : SportType.fromApi(state.uri.queryParameters['sport']),
          clubsFirst: state.uri.queryParameters['tab'] == 'clubs',
        ),
      ),
      GoRoute(
        path: '/courts',
        builder: (_, state) => CourtsScreen(
          sport: SportType.fromApi(state.uri.queryParameters['sport']),
          matchMode: state.uri.queryParameters['match'] == '1',
        ),
      ),
      GoRoute(path: '/matches/create', builder: (_, _) => const CreateMatchScreen()),
      GoRoute(
        path: '/match/:id',
        builder: (_, state) => MatchDetailsScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/match/:id/chat',
        builder: (_, state) => MatchChatScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/tournaments', builder: (_, _) => const TournamentsScreen()),
      GoRoute(path: '/tournaments/mine', builder: (_, _) => const MyTeamsScreen()),
      GoRoute(
        path: '/tournament/:id',
        builder: (_, state) => TournamentDetailsScreen(tournamentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/team/:id',
        builder: (_, state) => TeamScreen(teamId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/bookings/recurring', builder: (_, _) => const MyRecurringScreen()),
      GoRoute(
        path: '/court/:id/recurring',
        builder: (_, state) => RecurringBookingScreen(courtId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/owner', builder: (_, _) => const OwnerScreen()),
      GoRoute(path: '/owner/club/edit', builder: (_, _) => const ClubEditScreen()),
      GoRoute(path: '/owner/club/hours', builder: (_, _) => const WorkingHoursScreen()),
      GoRoute(path: '/owner/staff', builder: (_, _) => const StaffScreen()),
      GoRoute(path: '/owner/staff/new', builder: (_, _) => const StaffFormScreen()),
      GoRoute(path: '/owner/activity', builder: (_, _) => const ActivityScreen()),
      GoRoute(path: '/owner/tournaments/new', builder: (_, _) => const TournamentFormScreen()),
      GoRoute(
        path: '/owner/tournament/:id',
        builder: (_, state) => OwnerTournamentScreen(tournamentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/owner/club/photos', builder: (_, _) => const PhotosScreen()),
      GoRoute(
        path: '/owner/courts/:id/photos',
        builder: (_, state) => PhotosScreen(courtId: state.pathParameters['id']),
      ),
      GoRoute(path: '/owner/reports', builder: (_, _) => const ReportsScreen()),
      GoRoute(path: '/owner/bookings/new', builder: (_, _) => const ManualBookingScreen()),
      GoRoute(path: '/owner/courts/new', builder: (_, _) => const CourtFormScreen()),
      GoRoute(
        path: '/owner/courts/:id/edit',
        builder: (_, state) => CourtFormScreen(courtId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/owner/courts/:id/prices',
        builder: (_, state) => PriceRulesScreen(courtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/owner/courts/:id/slots',
        builder: (_, state) => CourtSlotsScreen(courtId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/membership', builder: (_, _) => const MembershipScreen()),
      GoRoute(path: '/reviews', builder: (_, _) => const MyReviewsScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/settings/password', builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: '/settings/notifications', builder: (_, _) => const NotificationPreferencesScreen()),
      GoRoute(path: '/post/create', builder: (_, _) => const CreatePostScreen()),
      GoRoute(
        path: '/post/:id',
        builder: (_, state) => PostDetailsScreen(postId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (_, state) => UserProfileScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/user/:id/followers',
        builder: (_, state) => FollowListScreen(userId: state.pathParameters['id']!, followers: true),
      ),
      GoRoute(
        path: '/user/:id/following',
        builder: (_, state) => FollowListScreen(userId: state.pathParameters['id']!, followers: false),
      ),
      GoRoute(path: '/profile/edit', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/messages', builder: (_, _) => const ConversationsScreen()),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => DirectChatScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(path: '/saved', builder: (_, _) => const SavedPostsScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (_, _) => const NotificationsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.matches, builder: (_, _) => const MatchesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.social, builder: (_, _) => const SocialScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.bookings, builder: (_, _) => const BookingsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
});

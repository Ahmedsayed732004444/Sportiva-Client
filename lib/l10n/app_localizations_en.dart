// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sportiva';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign up';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get rePassword => 'Re-Password';

  @override
  String get retypePassword => 'Retype your password';

  @override
  String get firstName => 'First name';

  @override
  String get enterFirstName => 'Enter your first name';

  @override
  String get lastName => 'Last name';

  @override
  String get enterLastName => 'Enter your last name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get signInLink => 'Sign in';

  @override
  String get orLoginWith => 'or login with';

  @override
  String get orSignUpWith => 'or sign up with';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get codeSentTo => 'We sent a code to';

  @override
  String get enterCodeHint => 'Enter the 6-digit code mentioned in the email';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get noEmailYet => 'Haven\'t got the email yet?';

  @override
  String get resendEmail => 'Resend email';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordHint => 'Please enter your email to reset your password';

  @override
  String get continueLabel => 'Continue';

  @override
  String get setNewPassword => 'Set a new password';

  @override
  String get setNewPasswordHint => 'Create a new password and make sure it differs from previous ones for security';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordRule => 'At least 8 characters with a digit, a lowercase letter, an uppercase letter and a symbol';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get nameTooShort => 'At least 3 characters';

  @override
  String get invalidCode => 'Enter the 6-digit code';

  @override
  String get networkError => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get unknownError => 'Something went wrong. Please try again.';

  @override
  String get googleNotConfigured => 'Google sign-in isn\'t set up yet.';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get emailConfirmed => 'Email confirmed. You can sign in now.';

  @override
  String get passwordUpdated => 'Password updated. You can sign in now.';

  @override
  String get codeResent => 'A new code was sent if the email needs one.';

  @override
  String get accountCreated => 'Account created. Check your email for the code.';

  @override
  String get emailNotConfirmedHint => 'Your email isn\'t confirmed yet. We sent you a code.';

  @override
  String welcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get navHome => 'Home';

  @override
  String get navMatches => 'Matches';

  @override
  String get navSocial => 'Community';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get retry => 'Try again';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get delete => 'Delete';

  @override
  String get nothingHere => 'Nothing here yet';

  @override
  String get timeNow => 'now';

  @override
  String timeMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String timeHours(int count) {
    return '${count}h ago';
  }

  @override
  String timeDays(int count) {
    return '${count}d ago';
  }

  @override
  String get language => 'Language';

  @override
  String get locationTitle => 'Find courts near you';

  @override
  String get locationBody =>
      'Allow location access so we can show the nearest courts and how far each one is from you.';

  @override
  String get allowLocation => 'Allow location';

  @override
  String get notNow => 'Not now';

  @override
  String get openSettings => 'Open settings';

  @override
  String get turnOnLocation => 'Turn on location';

  @override
  String get locationDeniedForever => 'Location access is blocked for the app. Enable it from the phone settings.';

  @override
  String get locationServiceOff => 'Location is turned off on your phone.';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get courtsNearYou => 'Courts near you';

  @override
  String courtsOfSport(String sport) {
    return '$sport courts';
  }

  @override
  String get noCourtsForSport => 'No courts for this sport yet';

  @override
  String get topRatedClubs => 'Top rated clubs';

  @override
  String get noClubsYet => 'No clubs yet';

  @override
  String get chooseSport => 'Choose a sport';

  @override
  String get sportFootball => 'Football';

  @override
  String get sportPadel => 'Padel';

  @override
  String get sportBasketball => 'Basketball';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportVolleyball => 'Volleyball';

  @override
  String get sportOther => 'Other';

  @override
  String perHour(String price) {
    return '$price EGP / hr';
  }

  @override
  String courtsCount(int count) {
    return '$count courts';
  }

  @override
  String get courts => 'Courts';

  @override
  String get workingHours => 'Working hours';

  @override
  String get reviews => 'Reviews';

  @override
  String get noReviews => 'No ratings yet';

  @override
  String get address => 'Address';

  @override
  String get callClub => 'Call';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get closed => 'Closed';

  @override
  String get allDay => 'Open';

  @override
  String get chooseDay => 'Choose the day';

  @override
  String get duration => 'Duration';

  @override
  String get courtPart => 'Court';

  @override
  String get fullCourt => 'Full court';

  @override
  String get halfA => 'Half A';

  @override
  String get halfB => 'Half B';

  @override
  String get playFormat => 'Play format';

  @override
  String get singles => 'Singles';

  @override
  String get doubles => 'Doubles';

  @override
  String get chooseTime => 'Choose the time';

  @override
  String get noTimesAvailable => 'No free times for this choice';

  @override
  String minutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String priceTotal(String price) {
    return '$price EGP';
  }

  @override
  String get total => 'Total';

  @override
  String get bookNow => 'Book now';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get bookingSummary => 'Booking summary';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectTimeFirst => 'Pick a time to continue';

  @override
  String get bookingConfirmed => 'Your booking is confirmed';

  @override
  String get bookingRequested => 'Request sent. The club will confirm it soon.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String bookingCode(String code) {
    return 'Booking $code';
  }

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelBookingBody => 'Do you want to cancel this booking?';

  @override
  String get cancelReasonHint => 'Reason (optional)';

  @override
  String get keepBooking => 'Keep it';

  @override
  String get bookingCancelled => 'Booking cancelled';

  @override
  String get bookingDetails => 'Booking details';

  @override
  String get court => 'Court';

  @override
  String get club => 'Club';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get status => 'Status';

  @override
  String get waitingForClub => 'Waiting for the club to confirm';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusNoShow => 'No show';

  @override
  String get statusExpired => 'Expired';

  @override
  String get reason => 'Reason';

  @override
  String timeRange(String from, String to) {
    return '$from - $to';
  }

  @override
  String get openMatches => 'Open matches';

  @override
  String get myMatches => 'My matches';

  @override
  String get allSports => 'All';

  @override
  String get noOpenMatches => 'No open matches right now';

  @override
  String get noMyMatches => 'You have no matches yet';

  @override
  String get createMatch => 'Create match';

  @override
  String get matchDetails => 'Match details';

  @override
  String get organizer => 'Organizer';

  @override
  String get players => 'Players';

  @override
  String playersCount(int joined, int needed) {
    return '$joined/$needed players';
  }

  @override
  String spotsLeft(int count) {
    return '$count spots left';
  }

  @override
  String get requestToJoin => 'Request to join';

  @override
  String get requestSent => 'Request sent';

  @override
  String get leaveMatch => 'Leave match';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get cancelMatch => 'Cancel match';

  @override
  String get cancelMatchBody => 'Cancel this match for everyone?';

  @override
  String get matchCancelled => 'Match cancelled';

  @override
  String get joinRequests => 'Join requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get noRequests => 'No pending requests';

  @override
  String get openChat => 'Match chat';

  @override
  String get matchStatusOpen => 'Open';

  @override
  String get matchStatusFull => 'Full';

  @override
  String get matchStatusInProgress => 'In progress';

  @override
  String get matchStatusCompleted => 'Completed';

  @override
  String get matchStatusCancelled => 'Cancelled';

  @override
  String get waitingClubConfirm => 'Waiting for the club to confirm the booking';

  @override
  String get sport => 'Sport';

  @override
  String get playersNeeded => 'Players needed';

  @override
  String get placeName => 'Place name';

  @override
  String get enterPlaceName => 'Enter the place name';

  @override
  String get city => 'City';

  @override
  String get enterCity => 'Enter the city';

  @override
  String get governorate => 'Governorate';

  @override
  String get note => 'Note (optional)';

  @override
  String get enterNote => 'Anything players should know';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get pickTime => 'Pick a time';

  @override
  String get matchCreated => 'Match created';

  @override
  String get openMatchFromBooking => 'Open this booking for players';

  @override
  String get openMatch => 'Open match';

  @override
  String get playersToFind => 'How many players do you need?';

  @override
  String get typeMessage => 'Type a message';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get send => 'Send';

  @override
  String playerRating(String rating) {
    return '$rating';
  }

  @override
  String get youAreOrganizer => 'You are the organizer';

  @override
  String get requestPending => 'Your request is pending';

  @override
  String get youAreIn => 'You are in this match';

  @override
  String get wholeDayHint => 'Times are on the hour or half hour';

  @override
  String get feed => 'Following';

  @override
  String get explore => 'Explore';

  @override
  String get reels => 'Reels';

  @override
  String get searchHint => 'Search people, clubs and posts';

  @override
  String get noPosts => 'No posts yet';

  @override
  String get newPostsAvailable => 'New posts';

  @override
  String get newPost => 'New post';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get addPhotos => 'Photos';

  @override
  String get addVideo => 'Video';

  @override
  String get publish => 'Publish';

  @override
  String get postProcessing => 'Your post is being prepared and will appear when it\'s ready.';

  @override
  String get postPublished => 'Post published';

  @override
  String get postFailed => 'This post couldn\'t be published';

  @override
  String get postEmpty => 'Write something or add a photo or video';

  @override
  String maxPhotos(int count) {
    return 'At most $count photos';
  }

  @override
  String get videoTooLarge => 'The video is too large (100 MB at most)';

  @override
  String likes(int count) {
    return '$count likes';
  }

  @override
  String get comments => 'Comments';

  @override
  String commentsCount(int count) {
    return '$count comments';
  }

  @override
  String get writeComment => 'Write a comment';

  @override
  String replyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get reply => 'Reply';

  @override
  String replies(int count) {
    return '$count replies';
  }

  @override
  String get hideReplies => 'Hide replies';

  @override
  String get noComments => 'No comments yet';

  @override
  String get deletePost => 'Delete post';

  @override
  String get deletePostBody => 'Delete this post?';

  @override
  String get editPost => 'Edit post';

  @override
  String get save => 'Save';

  @override
  String get report => 'Report';

  @override
  String get reportTitle => 'Why are you reporting this?';

  @override
  String get reportSent => 'Thanks, we\'ll review it';

  @override
  String get reasonSexualContent => 'Sexual content';

  @override
  String get reasonViolence => 'Violence';

  @override
  String get reasonHarassment => 'Harassment';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get reasonMisinformation => 'Misinformation';

  @override
  String get reasonImpersonation => 'Impersonation';

  @override
  String get reasonOther => 'Other';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String get blockBody => 'They won\'t be able to see your posts or message you.';

  @override
  String get blocked => 'User blocked';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get followBack => 'Follow back';

  @override
  String get followers => 'Followers';

  @override
  String get followingLabel => 'Following';

  @override
  String get postsLabel => 'Posts';

  @override
  String get message => 'Message';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get bio => 'Bio';

  @override
  String get enterBio => 'Tell people about you';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get online => 'Online';

  @override
  String get messages => 'Messages';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get noPeople => 'No people yet';

  @override
  String get you => 'You';

  @override
  String get viewReel => 'Reels';

  @override
  String get noReels => 'No reels yet';

  @override
  String get videoUnavailable => 'Video unavailable';

  @override
  String get searchPeople => 'People';

  @override
  String get searchClubs => 'Clubs';

  @override
  String get searchPosts => 'Posts';

  @override
  String get typeToSearch => 'Type to search';

  @override
  String get noResults => 'No results';

  @override
  String get viewProfile => 'View profile';

  @override
  String get videoPicked => 'Video selected';

  @override
  String get removeVideo => 'Remove video';

  @override
  String get showNewPosts => 'Show new posts';

  @override
  String get followersOf => 'Followers';

  @override
  String get followingOf => 'Following';

  @override
  String get blockedProfile => 'You blocked this person';

  @override
  String get sendFirstMessage => 'Say hello';

  @override
  String get tournaments => 'Tournaments';

  @override
  String get tournamentsSubtitle => 'Join a tournament or follow one';

  @override
  String get noTournaments => 'No tournaments right now';

  @override
  String get tournamentDetails => 'Tournament';

  @override
  String get tabInfo => 'Info';

  @override
  String get tabTeams => 'Teams';

  @override
  String get tabMatches => 'Matches';

  @override
  String get tabStandings => 'Standings';

  @override
  String get tournamentRegistrationOpen => 'Registration open';

  @override
  String get tournamentRegistrationClosed => 'Registration closed';

  @override
  String get tournamentInProgress => 'In progress';

  @override
  String get tournamentCompleted => 'Completed';

  @override
  String get tournamentCancelled => 'Cancelled';

  @override
  String get tournamentDraft => 'Draft';

  @override
  String get formatKnockout => 'Knockout';

  @override
  String get formatLeague => 'League';

  @override
  String get formatGroupsKnockout => 'Groups + knockout';

  @override
  String get individualTournament => 'Individual';

  @override
  String teamsCount(int joined, int max) {
    return '$joined/$max teams';
  }

  @override
  String get entryFee => 'Entry fee';

  @override
  String get free => 'Free';

  @override
  String feeAmount(String amount) {
    return '$amount EGP';
  }

  @override
  String get registrationCloses => 'Registration closes';

  @override
  String get startsOn => 'Starts';

  @override
  String get endsOn => 'Ends';

  @override
  String get tournamentFormat => 'Format';

  @override
  String get teamSize => 'Players per team';

  @override
  String teamSizeValue(int players, int subs) {
    return '$players + $subs substitutes';
  }

  @override
  String get matchLength => 'Match length';

  @override
  String get tournamentCourts => 'Courts';

  @override
  String get description => 'Description';

  @override
  String get rules => 'Rules';

  @override
  String get prizes => 'Prizes';

  @override
  String get champion => 'Champion';

  @override
  String cancellationReason(String reason) {
    return 'Cancelled: $reason';
  }

  @override
  String get registerTeam => 'Register a team';

  @override
  String get registerPlayer => 'Join the tournament';

  @override
  String get myTeam => 'My team';

  @override
  String get teamName => 'Team name';

  @override
  String get enterTeamName => 'Enter the team name';

  @override
  String get teamCreated => 'Team created';

  @override
  String get noTeams => 'No teams yet';

  @override
  String get noMatchesYet => 'The schedule isn\'t ready yet';

  @override
  String get noStandings => 'No standings yet';

  @override
  String get stageLeague => 'League';

  @override
  String stageGroup(int number) {
    return 'Group $number';
  }

  @override
  String get stageKnockout => 'Knockout';

  @override
  String roundLabel(int number) {
    return 'Round $number';
  }

  @override
  String get tbd => 'To be decided';

  @override
  String get bye => 'Bye';

  @override
  String get matchWaiting => 'Waiting';

  @override
  String get matchScheduled => 'Scheduled';

  @override
  String get matchDone => 'Finished';

  @override
  String get matchCancelledShort => 'Cancelled';

  @override
  String get colPlayed => 'P';

  @override
  String get colWon => 'W';

  @override
  String get colDrawn => 'D';

  @override
  String get colLost => 'L';

  @override
  String get colGoalDiff => 'GD';

  @override
  String get colPoints => 'Pts';

  @override
  String groupNumber(int number) {
    return 'Group $number';
  }

  @override
  String get teamStatusForming => 'Forming';

  @override
  String get teamStatusPendingPayment => 'Waiting for payment';

  @override
  String get teamStatusPendingApproval => 'Waiting for approval';

  @override
  String get teamStatusApproved => 'Approved';

  @override
  String get teamStatusRejected => 'Rejected';

  @override
  String get teamStatusWithdrawn => 'Withdrawn';

  @override
  String get teamStatusCancelled => 'Cancelled';

  @override
  String rejectionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get captain => 'Captain';

  @override
  String get substitute => 'Substitute';

  @override
  String get memberInvited => 'Invited';

  @override
  String get memberAccepted => 'Joined';

  @override
  String get memberDeclined => 'Declined';

  @override
  String get memberRemoved => 'Removed';

  @override
  String get invitePlayer => 'Invite a player';

  @override
  String get inviteAsSubstitute => 'As a substitute';

  @override
  String get inviteSent => 'Invitation sent';

  @override
  String get removeMember => 'Remove from team';

  @override
  String get payNow => 'Pay the entry fee';

  @override
  String get payWithCard => 'Card';

  @override
  String get payWithWallet => 'Mobile wallet';

  @override
  String get payHint => 'You\'ll finish the payment in your browser; the team updates by itself.';

  @override
  String get withdrawTeam => 'Withdraw the team';

  @override
  String get withdrawBody => 'Withdraw this team from the tournament?';

  @override
  String get withdrawn => 'Team withdrawn';

  @override
  String get myTeams => 'My teams';

  @override
  String get invitations => 'Invitations';

  @override
  String get noMyTeams => 'You haven\'t joined any tournament yet';

  @override
  String get noInvitations => 'No invitations';

  @override
  String invitedBy(String name) {
    return '$name invited you';
  }

  @override
  String get decline => 'Decline';

  @override
  String get invitationAccepted => 'You joined the team';

  @override
  String get invitationDeclined => 'Invitation declined';

  @override
  String get searchPlayers => 'Search for a player';

  @override
  String get teamsAndInvitations => 'My teams and invitations';

  @override
  String get allTournamentSports => 'All sports';

  @override
  String get openTournaments => 'Open for registration';

  @override
  String get rateCourt => 'Rate this court';

  @override
  String get ratePlayers => 'Rate the players';

  @override
  String get yourRating => 'Your rating';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get submitReview => 'Send rating';

  @override
  String get reviewSent => 'Thanks for your rating';

  @override
  String get myReviews => 'My ratings';

  @override
  String get reviewsWritten => 'Given';

  @override
  String get reviewsReceived => 'Received';

  @override
  String get reviewHiddenUntil => 'Hidden until the rating window ends';

  @override
  String get deleteReview => 'Delete rating';

  @override
  String get reviewDeleted => 'Rating deleted';

  @override
  String get rated => 'Rated';

  @override
  String get tapToRate => 'Tap a player to rate them';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get phone => 'Phone';

  @override
  String get enterPhone => 'Enter your mobile number';

  @override
  String get savePhone => 'Save';

  @override
  String get phoneSaved => 'Phone saved';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get inApp => 'In the app';

  @override
  String get byEmail => 'By email';

  @override
  String get categoryBookings => 'Bookings and ratings';

  @override
  String get categoryPayments => 'Payments and subscriptions';

  @override
  String get categoryMatches => 'Matches';

  @override
  String get categorySocial => 'Social and messages';

  @override
  String get categoryTournaments => 'Tournaments';

  @override
  String get categoryAccount => 'Account and system';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountBody => 'Your account will be closed and your data erased. This can\'t be undone.';

  @override
  String get deleteAccountConfirm => 'Delete';

  @override
  String get deletionRequested => 'Your account will be deleted';

  @override
  String get manageClub => 'Manage my club';

  @override
  String get invalidPhone => 'Enter a valid Egyptian mobile number';

  @override
  String get ownerTitle => 'My club';

  @override
  String get ownerBookings => 'Bookings';

  @override
  String get ownerCourts => 'Courts';

  @override
  String get ownerTournaments => 'Tournaments';

  @override
  String get ownerClub => 'Club';

  @override
  String get tabPending => 'Requests';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabPast => 'Past';

  @override
  String get noOwnerBookings => 'No bookings here';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get rejectAction => 'Reject';

  @override
  String get rejectBookingTitle => 'Reject this booking';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get cancelBookingAction => 'Cancel booking';

  @override
  String get markCompleted => 'Mark as played';

  @override
  String get markNoShow => 'No-show';

  @override
  String get ratePlayer => 'Rate the player';

  @override
  String get customer => 'Customer';

  @override
  String get walkInCustomer => 'Walk-in customer';

  @override
  String get manualBooking => 'New booking';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerPhone => 'Customer phone';

  @override
  String get customerEmail => 'Customer email (optional)';

  @override
  String get selectCourt => 'Court';

  @override
  String get bookingCreated => 'Booking created';

  @override
  String get bookingUpdated => 'Done';

  @override
  String get playFormatLabel => 'Play format';

  @override
  String get courtPartLabel => 'Court part';

  @override
  String get callCustomer => 'Call';

  @override
  String needsReply(String time) {
    return 'Reply before $time';
  }

  @override
  String get addCourt => 'Add a court';

  @override
  String get editCourt => 'Edit court';

  @override
  String get courtName => 'Court name';

  @override
  String get enterCourtName => 'Enter the court name';

  @override
  String get confirmationMode => 'Booking confirmation';

  @override
  String get modeManual => 'I confirm each booking';

  @override
  String get modeAutomatic => 'Automatic';

  @override
  String get responseTimeout => 'Reply within (minutes)';

  @override
  String get pricePerHour => 'Price per hour (EGP)';

  @override
  String get enterPrice => 'Enter the price';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get allowsHalfCourt => 'Half court bookings';

  @override
  String get halfCourtPrice => 'Half court price per hour (EGP)';

  @override
  String get courtSaved => 'Court saved';

  @override
  String get courtDeleted => 'Court deleted';

  @override
  String get deleteCourt => 'Delete court';

  @override
  String get deleteCourtBody => 'Delete this court? Its upcoming bookings must be cancelled first.';

  @override
  String get courtActive => 'Open for booking';

  @override
  String get priceRules => 'Price rules';

  @override
  String get priceRulesHint => 'Different prices for certain days and hours';

  @override
  String get addRule => 'Add a rule';

  @override
  String get anyDay => 'Every day';

  @override
  String get ruleFrom => 'From';

  @override
  String get ruleTo => 'To';

  @override
  String get slotsAndClosing => 'Close times';

  @override
  String get slotsHint => 'Tap a time to close it for booking, tap again to open it';

  @override
  String get slotBooked => 'Booked';

  @override
  String get pricesSaved => 'Prices saved';

  @override
  String get noCourts => 'No courts yet';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get clubOpen => 'Club open for booking';

  @override
  String get editClubInfo => 'Club details';

  @override
  String get clubSaved => 'Club saved';

  @override
  String get hoursSaved => 'Hours saved';

  @override
  String get mapUrl => 'Map link (optional)';

  @override
  String get clubPhone => 'Club phone';

  @override
  String get clubEmail => 'Club email (optional)';

  @override
  String get changeLogo => 'Change logo';

  @override
  String get changeCover => 'Change cover';

  @override
  String get photoUpdated => 'Photo updated';

  @override
  String get subscription => 'Subscription';

  @override
  String get subNone => 'No active subscription';

  @override
  String get subActive => 'Active';

  @override
  String get subGrace => 'Grace period - renew now';

  @override
  String get subExpired => 'Expired';

  @override
  String get subPlan => 'Plan';

  @override
  String get subEnds => 'Ends';

  @override
  String subCourts(int used, int max) {
    return '$used of $max courts';
  }

  @override
  String get renewNow => 'Renew';

  @override
  String get subscribeNow => 'Subscribe';

  @override
  String get choosePlan => 'Choose a plan';

  @override
  String planDetails(String price, int courts, int days) {
    return '$price EGP · $courts courts · $days days';
  }

  @override
  String get staff => 'Staff';

  @override
  String get noStaff => 'No staff yet';

  @override
  String get addStaff => 'Add a staff member';

  @override
  String get firstName2 => 'First name';

  @override
  String get staffPermissions => 'Permissions';

  @override
  String get staffCourts => 'Courts (none selected = all)';

  @override
  String get staffAdded => 'Staff member added';

  @override
  String get staffRemoved => 'Removed';

  @override
  String get removeStaff => 'Remove';

  @override
  String get activateStaff => 'Active';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get passwordReset => 'Password changed';

  @override
  String get activityLog => 'Activity';

  @override
  String get noActivity => 'No activity yet';

  @override
  String get permManageBookings => 'Manage bookings';

  @override
  String get permManualBookings => 'Manual bookings';

  @override
  String get permViewReports => 'View reports';

  @override
  String get permCheckIn => 'Check-in';

  @override
  String get permManageSlots => 'Close times';

  @override
  String get permRatePlayers => 'Rate players';

  @override
  String get permTournamentResults => 'Tournament results';

  @override
  String get permEditCourts => 'Edit courts';

  @override
  String get permManageTournaments => 'Manage tournaments';

  @override
  String get createTournament => 'New tournament';

  @override
  String get tournamentName => 'Tournament name';

  @override
  String get enterTournamentName => 'Enter the tournament name';

  @override
  String get rulesField => 'Rules (optional)';

  @override
  String get prizesField => 'Prizes (optional)';

  @override
  String get individualSwitch => 'Individual (one player per entry)';

  @override
  String get playersPerTeamLabel => 'Players per team';

  @override
  String get substitutesLabel => 'Substitutes per team';

  @override
  String get maxTeamsLabel => 'Maximum teams';

  @override
  String get groupsCountLabel => 'Number of groups';

  @override
  String get qualifiersLabel => 'Qualifiers per group';

  @override
  String get registrationCloseLabel => 'Registration closes';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get endDateLabel => 'End date';

  @override
  String get dailyStartLabel => 'Daily start';

  @override
  String get dailyEndLabel => 'Daily end';

  @override
  String get matchMinutesLabel => 'Match length';

  @override
  String get pickCourts => 'Courts used';

  @override
  String get tournamentCreated => 'Tournament created';

  @override
  String get publishTournament => 'Publish';

  @override
  String get closeRegistration => 'Close registration';

  @override
  String get drawTournament => 'Draw and schedule';

  @override
  String get cancelTournament => 'Cancel tournament';

  @override
  String get cancelTournamentTitle => 'Cancel this tournament?';

  @override
  String get cancelReasonRequired => 'Reason (required)';

  @override
  String get tournamentActionDone => 'Done';

  @override
  String get approveTeam => 'Approve';

  @override
  String get rejectTeam => 'Reject';

  @override
  String get rejectTeamTitle => 'Reject this team';

  @override
  String get noManagedTournaments => 'You haven\'t created a tournament yet';

  @override
  String get enterResult => 'Enter result';

  @override
  String get homeScore => 'Home score';

  @override
  String get awayScore => 'Away score';

  @override
  String get winnerOnDraw => 'Winner (needed on a draw)';

  @override
  String get resultSaved => 'Result saved';

  @override
  String get pickPoster => 'Change poster';

  @override
  String get teamsPending => 'Waiting for you';

  @override
  String get mustPickCourt => 'Pick at least one court';
}

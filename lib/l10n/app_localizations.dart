import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sportiva'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @rePassword.
  ///
  /// In en, this message translates to:
  /// **'Re-Password'**
  String get rePassword;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype your password'**
  String get retypePassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'or login with'**
  String get orLoginWith;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWith;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to'**
  String get codeSentTo;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code mentioned in the email'**
  String get enterCodeHint;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @noEmailYet.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t got the email yet?'**
  String get noEmailYet;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to reset your password'**
  String get forgotPasswordHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @setNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a new password and make sure it differs from previous ones for security'**
  String get setNewPasswordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters with a digit, a lowercase letter, an uppercase letter and a symbol'**
  String get passwordRule;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get nameTooShort;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get invalidCode;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// No description provided for @googleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn\'t set up yet.'**
  String get googleNotConfigured;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @emailConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed. You can sign in now.'**
  String get emailConfirmed;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in now.'**
  String get passwordUpdated;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent if the email needs one.'**
  String get codeResent;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email for the code.'**
  String get accountCreated;

  /// No description provided for @emailNotConfirmedHint.
  ///
  /// In en, this message translates to:
  /// **'Your email isn\'t confirmed yet. We sent you a code.'**
  String get emailNotConfirmedHint;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcome(String name);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchLanguage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navSocial.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navSocial;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHere;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutes(int count);

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHours(int count);

  /// No description provided for @timeDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDays(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Find courts near you'**
  String get locationTitle;

  /// No description provided for @locationBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location access so we can show the nearest courts and how far each one is from you.'**
  String get locationBody;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @turnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get turnOnLocation;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked for the app. Enable it from the phone settings.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on your phone.'**
  String get locationServiceOff;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @courtsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Courts near you'**
  String get courtsNearYou;

  /// No description provided for @courtsOfSport.
  ///
  /// In en, this message translates to:
  /// **'{sport} courts'**
  String courtsOfSport(String sport);

  /// No description provided for @noCourtsForSport.
  ///
  /// In en, this message translates to:
  /// **'No courts for this sport yet'**
  String get noCourtsForSport;

  /// No description provided for @topRatedClubs.
  ///
  /// In en, this message translates to:
  /// **'Top rated clubs'**
  String get topRatedClubs;

  /// No description provided for @noClubsYet.
  ///
  /// In en, this message translates to:
  /// **'No clubs yet'**
  String get noClubsYet;

  /// No description provided for @chooseSport.
  ///
  /// In en, this message translates to:
  /// **'Choose a sport'**
  String get chooseSport;

  /// No description provided for @sportFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get sportFootball;

  /// No description provided for @sportPadel.
  ///
  /// In en, this message translates to:
  /// **'Padel'**
  String get sportPadel;

  /// No description provided for @sportBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get sportBasketball;

  /// No description provided for @sportTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get sportTennis;

  /// No description provided for @sportVolleyball.
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get sportVolleyball;

  /// No description provided for @sportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sportOther;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'{price} EGP / hr'**
  String perHour(String price);

  /// No description provided for @courtsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} courts'**
  String courtsCount(int count);

  /// No description provided for @courts.
  ///
  /// In en, this message translates to:
  /// **'Courts'**
  String get courts;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get noReviews;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @callClub.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callClub;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get allDay;

  /// No description provided for @chooseDay.
  ///
  /// In en, this message translates to:
  /// **'Choose the day'**
  String get chooseDay;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @courtPart.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get courtPart;

  /// No description provided for @fullCourt.
  ///
  /// In en, this message translates to:
  /// **'Full court'**
  String get fullCourt;

  /// No description provided for @halfA.
  ///
  /// In en, this message translates to:
  /// **'Half A'**
  String get halfA;

  /// No description provided for @halfB.
  ///
  /// In en, this message translates to:
  /// **'Half B'**
  String get halfB;

  /// No description provided for @playFormat.
  ///
  /// In en, this message translates to:
  /// **'Play format'**
  String get playFormat;

  /// No description provided for @singles.
  ///
  /// In en, this message translates to:
  /// **'Singles'**
  String get singles;

  /// No description provided for @doubles.
  ///
  /// In en, this message translates to:
  /// **'Doubles'**
  String get doubles;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose the time'**
  String get chooseTime;

  /// No description provided for @noTimesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No free times for this choice'**
  String get noTimesAvailable;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesLabel(int minutes);

  /// No description provided for @priceTotal.
  ///
  /// In en, this message translates to:
  /// **'{price} EGP'**
  String priceTotal(String price);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking summary'**
  String get bookingSummary;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a time to continue'**
  String get selectTimeFirst;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your booking is confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingRequested.
  ///
  /// In en, this message translates to:
  /// **'Request sent. The club will confirm it soon.'**
  String get bookingRequested;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @bookingCode.
  ///
  /// In en, this message translates to:
  /// **'Booking {code}'**
  String bookingCode(String code);

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @cancelBookingBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel this booking?'**
  String get cancelBookingBody;

  /// No description provided for @cancelReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get cancelReasonHint;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepBooking;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get bookingCancelled;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetails;

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get court;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get club;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @waitingForClub.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the club to confirm'**
  String get waitingForClub;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get statusNoShow;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{from} - {to}'**
  String timeRange(String from, String to);

  /// No description provided for @openMatches.
  ///
  /// In en, this message translates to:
  /// **'Open matches'**
  String get openMatches;

  /// No description provided for @myMatches.
  ///
  /// In en, this message translates to:
  /// **'My matches'**
  String get myMatches;

  /// No description provided for @allSports.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allSports;

  /// No description provided for @noOpenMatches.
  ///
  /// In en, this message translates to:
  /// **'No open matches right now'**
  String get noOpenMatches;

  /// No description provided for @noMyMatches.
  ///
  /// In en, this message translates to:
  /// **'You have no matches yet'**
  String get noMyMatches;

  /// No description provided for @createMatch.
  ///
  /// In en, this message translates to:
  /// **'Create match'**
  String get createMatch;

  /// No description provided for @matchDetails.
  ///
  /// In en, this message translates to:
  /// **'Match details'**
  String get matchDetails;

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{joined}/{needed} players'**
  String playersCount(int joined, int needed);

  /// No description provided for @spotsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} spots left'**
  String spotsLeft(int count);

  /// No description provided for @requestToJoin.
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get requestToJoin;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @leaveMatch.
  ///
  /// In en, this message translates to:
  /// **'Leave match'**
  String get leaveMatch;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @cancelMatch.
  ///
  /// In en, this message translates to:
  /// **'Cancel match'**
  String get cancelMatch;

  /// No description provided for @cancelMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Cancel this match for everyone?'**
  String get cancelMatchBody;

  /// No description provided for @matchCancelled.
  ///
  /// In en, this message translates to:
  /// **'Match cancelled'**
  String get matchCancelled;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join requests'**
  String get joinRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noRequests;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Match chat'**
  String get openChat;

  /// No description provided for @matchStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get matchStatusOpen;

  /// No description provided for @matchStatusFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get matchStatusFull;

  /// No description provided for @matchStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get matchStatusInProgress;

  /// No description provided for @matchStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get matchStatusCompleted;

  /// No description provided for @matchStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get matchStatusCancelled;

  /// No description provided for @waitingClubConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the club to confirm the booking'**
  String get waitingClubConfirm;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @playersNeeded.
  ///
  /// In en, this message translates to:
  /// **'Players needed'**
  String get playersNeeded;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get placeName;

  /// No description provided for @enterPlaceName.
  ///
  /// In en, this message translates to:
  /// **'Enter the place name'**
  String get enterPlaceName;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter the city'**
  String get enterCity;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get note;

  /// No description provided for @enterNote.
  ///
  /// In en, this message translates to:
  /// **'Anything players should know'**
  String get enterNote;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get pickTime;

  /// No description provided for @matchCreated.
  ///
  /// In en, this message translates to:
  /// **'Match created'**
  String get matchCreated;

  /// No description provided for @openMatchFromBooking.
  ///
  /// In en, this message translates to:
  /// **'Open this booking for players'**
  String get openMatchFromBooking;

  /// No description provided for @openMatch.
  ///
  /// In en, this message translates to:
  /// **'Open match'**
  String get openMatch;

  /// No description provided for @playersToFind.
  ///
  /// In en, this message translates to:
  /// **'How many players do you need?'**
  String get playersToFind;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @playerRating.
  ///
  /// In en, this message translates to:
  /// **'{rating}'**
  String playerRating(String rating);

  /// No description provided for @youAreOrganizer.
  ///
  /// In en, this message translates to:
  /// **'You are the organizer'**
  String get youAreOrganizer;

  /// No description provided for @requestPending.
  ///
  /// In en, this message translates to:
  /// **'Your request is pending'**
  String get requestPending;

  /// No description provided for @youAreIn.
  ///
  /// In en, this message translates to:
  /// **'You are in this match'**
  String get youAreIn;

  /// No description provided for @wholeDayHint.
  ///
  /// In en, this message translates to:
  /// **'Times are on the hour or half hour'**
  String get wholeDayHint;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get feed;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get reels;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, clubs and posts'**
  String get searchHint;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPosts;

  /// No description provided for @newPostsAvailable.
  ///
  /// In en, this message translates to:
  /// **'New posts'**
  String get newPostsAvailable;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPost;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get addPhotos;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get addVideo;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @postProcessing.
  ///
  /// In en, this message translates to:
  /// **'Your post is being prepared and will appear when it\'s ready.'**
  String get postProcessing;

  /// No description provided for @postPublished.
  ///
  /// In en, this message translates to:
  /// **'Post published'**
  String get postPublished;

  /// No description provided for @postFailed.
  ///
  /// In en, this message translates to:
  /// **'This post couldn\'t be published'**
  String get postFailed;

  /// No description provided for @postEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write something or add a photo or video'**
  String get postEmpty;

  /// No description provided for @maxPhotos.
  ///
  /// In en, this message translates to:
  /// **'At most {count} photos'**
  String maxPhotos(int count);

  /// No description provided for @videoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The video is too large (100 MB at most)'**
  String get videoTooLarge;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likes(int count);

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentsCount(int count);

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get writeComment;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String replyingTo(String name);

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String replies(int count);

  /// No description provided for @hideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get hideReplies;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get deletePost;

  /// No description provided for @deletePostBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get deletePostBody;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPost;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this?'**
  String get reportTitle;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks, we\'ll review it'**
  String get reportSent;

  /// No description provided for @reasonSexualContent.
  ///
  /// In en, this message translates to:
  /// **'Sexual content'**
  String get reasonSexualContent;

  /// No description provided for @reasonViolence.
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get reasonViolence;

  /// No description provided for @reasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reasonHarassment;

  /// No description provided for @reasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @reasonMisinformation.
  ///
  /// In en, this message translates to:
  /// **'Misinformation'**
  String get reasonMisinformation;

  /// No description provided for @reasonImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get reasonImpersonation;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @blockBody.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to see your posts or message you.'**
  String get blockBody;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get blocked;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @followBack.
  ///
  /// In en, this message translates to:
  /// **'Follow back'**
  String get followBack;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @followingLabel.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingLabel;

  /// No description provided for @postsLabel.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsLabel;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @enterBio.
  ///
  /// In en, this message translates to:
  /// **'Tell people about you'**
  String get enterBio;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @noPeople.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get noPeople;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @viewReel.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get viewReel;

  /// No description provided for @noReels.
  ///
  /// In en, this message translates to:
  /// **'No reels yet'**
  String get noReels;

  /// No description provided for @videoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnavailable;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchPeople;

  /// No description provided for @searchClubs.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get searchClubs;

  /// No description provided for @searchPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get searchPosts;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search'**
  String get typeToSearch;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @videoPicked.
  ///
  /// In en, this message translates to:
  /// **'Video selected'**
  String get videoPicked;

  /// No description provided for @removeVideo.
  ///
  /// In en, this message translates to:
  /// **'Remove video'**
  String get removeVideo;

  /// No description provided for @showNewPosts.
  ///
  /// In en, this message translates to:
  /// **'Show new posts'**
  String get showNewPosts;

  /// No description provided for @followersOf.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersOf;

  /// No description provided for @followingOf.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingOf;

  /// No description provided for @blockedProfile.
  ///
  /// In en, this message translates to:
  /// **'You blocked this person'**
  String get blockedProfile;

  /// No description provided for @sendFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get sendFirstMessage;

  /// No description provided for @tournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournaments;

  /// No description provided for @tournamentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a tournament or follow one'**
  String get tournamentsSubtitle;

  /// No description provided for @noTournaments.
  ///
  /// In en, this message translates to:
  /// **'No tournaments right now'**
  String get noTournaments;

  /// No description provided for @tournamentDetails.
  ///
  /// In en, this message translates to:
  /// **'Tournament'**
  String get tournamentDetails;

  /// No description provided for @tabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tabInfo;

  /// No description provided for @tabTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get tabTeams;

  /// No description provided for @tabMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get tabMatches;

  /// No description provided for @tabStandings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get tabStandings;

  /// No description provided for @tournamentRegistrationOpen.
  ///
  /// In en, this message translates to:
  /// **'Registration open'**
  String get tournamentRegistrationOpen;

  /// No description provided for @tournamentRegistrationClosed.
  ///
  /// In en, this message translates to:
  /// **'Registration closed'**
  String get tournamentRegistrationClosed;

  /// No description provided for @tournamentInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get tournamentInProgress;

  /// No description provided for @tournamentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tournamentCompleted;

  /// No description provided for @tournamentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tournamentCancelled;

  /// No description provided for @tournamentDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get tournamentDraft;

  /// No description provided for @formatKnockout.
  ///
  /// In en, this message translates to:
  /// **'Knockout'**
  String get formatKnockout;

  /// No description provided for @formatLeague.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get formatLeague;

  /// No description provided for @formatGroupsKnockout.
  ///
  /// In en, this message translates to:
  /// **'Groups + knockout'**
  String get formatGroupsKnockout;

  /// No description provided for @individualTournament.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualTournament;

  /// No description provided for @teamsCount.
  ///
  /// In en, this message translates to:
  /// **'{joined}/{max} teams'**
  String teamsCount(int joined, int max);

  /// No description provided for @entryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry fee'**
  String get entryFee;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @feeAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} EGP'**
  String feeAmount(String amount);

  /// No description provided for @registrationCloses.
  ///
  /// In en, this message translates to:
  /// **'Registration closes'**
  String get registrationCloses;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startsOn;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsOn;

  /// No description provided for @tournamentFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get tournamentFormat;

  /// No description provided for @teamSize.
  ///
  /// In en, this message translates to:
  /// **'Players per team'**
  String get teamSize;

  /// No description provided for @teamSizeValue.
  ///
  /// In en, this message translates to:
  /// **'{players} + {subs} substitutes'**
  String teamSizeValue(int players, int subs);

  /// No description provided for @matchLength.
  ///
  /// In en, this message translates to:
  /// **'Match length'**
  String get matchLength;

  /// No description provided for @tournamentCourts.
  ///
  /// In en, this message translates to:
  /// **'Courts'**
  String get tournamentCourts;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @prizes.
  ///
  /// In en, this message translates to:
  /// **'Prizes'**
  String get prizes;

  /// No description provided for @champion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get champion;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancelled: {reason}'**
  String cancellationReason(String reason);

  /// No description provided for @registerTeam.
  ///
  /// In en, this message translates to:
  /// **'Register a team'**
  String get registerTeam;

  /// No description provided for @registerPlayer.
  ///
  /// In en, this message translates to:
  /// **'Join the tournament'**
  String get registerPlayer;

  /// No description provided for @myTeam.
  ///
  /// In en, this message translates to:
  /// **'My team'**
  String get myTeam;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get teamName;

  /// No description provided for @enterTeamName.
  ///
  /// In en, this message translates to:
  /// **'Enter the team name'**
  String get enterTeamName;

  /// No description provided for @teamCreated.
  ///
  /// In en, this message translates to:
  /// **'Team created'**
  String get teamCreated;

  /// No description provided for @noTeams.
  ///
  /// In en, this message translates to:
  /// **'No teams yet'**
  String get noTeams;

  /// No description provided for @noMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'The schedule isn\'t ready yet'**
  String get noMatchesYet;

  /// No description provided for @noStandings.
  ///
  /// In en, this message translates to:
  /// **'No standings yet'**
  String get noStandings;

  /// No description provided for @stageLeague.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get stageLeague;

  /// No description provided for @stageGroup.
  ///
  /// In en, this message translates to:
  /// **'Group {number}'**
  String stageGroup(int number);

  /// No description provided for @stageKnockout.
  ///
  /// In en, this message translates to:
  /// **'Knockout'**
  String get stageKnockout;

  /// No description provided for @roundLabel.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundLabel(int number);

  /// No description provided for @tbd.
  ///
  /// In en, this message translates to:
  /// **'To be decided'**
  String get tbd;

  /// No description provided for @bye.
  ///
  /// In en, this message translates to:
  /// **'Bye'**
  String get bye;

  /// No description provided for @matchWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get matchWaiting;

  /// No description provided for @matchScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get matchScheduled;

  /// No description provided for @matchDone.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get matchDone;

  /// No description provided for @matchCancelledShort.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get matchCancelledShort;

  /// No description provided for @colPlayed.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get colPlayed;

  /// No description provided for @colWon.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get colWon;

  /// No description provided for @colDrawn.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get colDrawn;

  /// No description provided for @colLost.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get colLost;

  /// No description provided for @colGoalDiff.
  ///
  /// In en, this message translates to:
  /// **'GD'**
  String get colGoalDiff;

  /// No description provided for @colPoints.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get colPoints;

  /// No description provided for @groupNumber.
  ///
  /// In en, this message translates to:
  /// **'Group {number}'**
  String groupNumber(int number);

  /// No description provided for @teamStatusForming.
  ///
  /// In en, this message translates to:
  /// **'Forming'**
  String get teamStatusForming;

  /// No description provided for @teamStatusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get teamStatusPendingPayment;

  /// No description provided for @teamStatusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get teamStatusPendingApproval;

  /// No description provided for @teamStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get teamStatusApproved;

  /// No description provided for @teamStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get teamStatusRejected;

  /// No description provided for @teamStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get teamStatusWithdrawn;

  /// No description provided for @teamStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get teamStatusCancelled;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String rejectionReason(String reason);

  /// No description provided for @captain.
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captain;

  /// No description provided for @substitute.
  ///
  /// In en, this message translates to:
  /// **'Substitute'**
  String get substitute;

  /// No description provided for @memberInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get memberInvited;

  /// No description provided for @memberAccepted.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get memberAccepted;

  /// No description provided for @memberDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get memberDeclined;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get memberRemoved;

  /// No description provided for @invitePlayer.
  ///
  /// In en, this message translates to:
  /// **'Invite a player'**
  String get invitePlayer;

  /// No description provided for @inviteAsSubstitute.
  ///
  /// In en, this message translates to:
  /// **'As a substitute'**
  String get inviteAsSubstitute;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get inviteSent;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from team'**
  String get removeMember;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay the entry fee'**
  String get payNow;

  /// No description provided for @payWithCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payWithCard;

  /// No description provided for @payWithWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile wallet'**
  String get payWithWallet;

  /// No description provided for @payHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll finish the payment in your browser; the team updates by itself.'**
  String get payHint;

  /// No description provided for @withdrawTeam.
  ///
  /// In en, this message translates to:
  /// **'Withdraw the team'**
  String get withdrawTeam;

  /// No description provided for @withdrawBody.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this team from the tournament?'**
  String get withdrawBody;

  /// No description provided for @withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Team withdrawn'**
  String get withdrawn;

  /// No description provided for @myTeams.
  ///
  /// In en, this message translates to:
  /// **'My teams'**
  String get myTeams;

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @noMyTeams.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined any tournament yet'**
  String get noMyTeams;

  /// No description provided for @noInvitations.
  ///
  /// In en, this message translates to:
  /// **'No invitations'**
  String get noInvitations;

  /// No description provided for @invitedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you'**
  String invitedBy(String name);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'You joined the team'**
  String get invitationAccepted;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// No description provided for @searchPlayers.
  ///
  /// In en, this message translates to:
  /// **'Search for a player'**
  String get searchPlayers;

  /// No description provided for @teamsAndInvitations.
  ///
  /// In en, this message translates to:
  /// **'My teams and invitations'**
  String get teamsAndInvitations;

  /// No description provided for @allTournamentSports.
  ///
  /// In en, this message translates to:
  /// **'All sports'**
  String get allTournamentSports;

  /// No description provided for @openTournaments.
  ///
  /// In en, this message translates to:
  /// **'Open for registration'**
  String get openTournaments;

  /// No description provided for @rateCourt.
  ///
  /// In en, this message translates to:
  /// **'Rate this court'**
  String get rateCourt;

  /// No description provided for @ratePlayers.
  ///
  /// In en, this message translates to:
  /// **'Rate the players'**
  String get ratePlayers;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Send rating'**
  String get submitReview;

  /// No description provided for @reviewSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your rating'**
  String get reviewSent;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My ratings'**
  String get myReviews;

  /// No description provided for @reviewsWritten.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get reviewsWritten;

  /// No description provided for @reviewsReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get reviewsReceived;

  /// No description provided for @reviewHiddenUntil.
  ///
  /// In en, this message translates to:
  /// **'Hidden until the rating window ends'**
  String get reviewHiddenUntil;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete rating'**
  String get deleteReview;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Rating deleted'**
  String get reviewDeleted;

  /// No description provided for @rated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get rated;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a player to rate them'**
  String get tapToRate;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get enterPhone;

  /// No description provided for @savePhone.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savePhone;

  /// No description provided for @phoneSaved.
  ///
  /// In en, this message translates to:
  /// **'Phone saved'**
  String get phoneSaved;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @inApp.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get inApp;

  /// No description provided for @byEmail.
  ///
  /// In en, this message translates to:
  /// **'By email'**
  String get byEmail;

  /// No description provided for @categoryBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings and ratings'**
  String get categoryBookings;

  /// No description provided for @categoryPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments and subscriptions'**
  String get categoryPayments;

  /// No description provided for @categoryMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get categoryMatches;

  /// No description provided for @categorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social and messages'**
  String get categorySocial;

  /// No description provided for @categoryTournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get categoryTournaments;

  /// No description provided for @categoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account and system'**
  String get categoryAccount;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be closed and your data erased. This can\'t be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountConfirm;

  /// No description provided for @deletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted'**
  String get deletionRequested;

  /// No description provided for @manageClub.
  ///
  /// In en, this message translates to:
  /// **'Manage my club'**
  String get manageClub;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian mobile number'**
  String get invalidPhone;

  /// No description provided for @ownerTitle.
  ///
  /// In en, this message translates to:
  /// **'My club'**
  String get ownerTitle;

  /// No description provided for @ownerBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get ownerBookings;

  /// No description provided for @ownerCourts.
  ///
  /// In en, this message translates to:
  /// **'Courts'**
  String get ownerCourts;

  /// No description provided for @ownerTournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get ownerTournaments;

  /// No description provided for @ownerClub.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get ownerClub;

  /// No description provided for @tabPending.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get tabPending;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tabPast;

  /// No description provided for @noOwnerBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings here'**
  String get noOwnerBookings;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAction;

  /// No description provided for @rejectBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this booking'**
  String get rejectBookingTitle;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @cancelBookingAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBookingAction;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as played'**
  String get markCompleted;

  /// No description provided for @markNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get markNoShow;

  /// No description provided for @ratePlayer.
  ///
  /// In en, this message translates to:
  /// **'Rate the player'**
  String get ratePlayer;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer'**
  String get walkInCustomer;

  /// No description provided for @manualBooking.
  ///
  /// In en, this message translates to:
  /// **'New booking'**
  String get manualBooking;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get customerPhone;

  /// No description provided for @customerEmail.
  ///
  /// In en, this message translates to:
  /// **'Customer email (optional)'**
  String get customerEmail;

  /// No description provided for @selectCourt.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get selectCourt;

  /// No description provided for @bookingCreated.
  ///
  /// In en, this message translates to:
  /// **'Booking created'**
  String get bookingCreated;

  /// No description provided for @bookingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get bookingUpdated;

  /// No description provided for @playFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Play format'**
  String get playFormatLabel;

  /// No description provided for @courtPartLabel.
  ///
  /// In en, this message translates to:
  /// **'Court part'**
  String get courtPartLabel;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callCustomer;

  /// No description provided for @needsReply.
  ///
  /// In en, this message translates to:
  /// **'Reply before {time}'**
  String needsReply(String time);

  /// No description provided for @addCourt.
  ///
  /// In en, this message translates to:
  /// **'Add a court'**
  String get addCourt;

  /// No description provided for @editCourt.
  ///
  /// In en, this message translates to:
  /// **'Edit court'**
  String get editCourt;

  /// No description provided for @courtName.
  ///
  /// In en, this message translates to:
  /// **'Court name'**
  String get courtName;

  /// No description provided for @enterCourtName.
  ///
  /// In en, this message translates to:
  /// **'Enter the court name'**
  String get enterCourtName;

  /// No description provided for @confirmationMode.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmation'**
  String get confirmationMode;

  /// No description provided for @modeManual.
  ///
  /// In en, this message translates to:
  /// **'I confirm each booking'**
  String get modeManual;

  /// No description provided for @modeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get modeAutomatic;

  /// No description provided for @responseTimeout.
  ///
  /// In en, this message translates to:
  /// **'Reply within (minutes)'**
  String get responseTimeout;

  /// No description provided for @pricePerHour.
  ///
  /// In en, this message translates to:
  /// **'Price per hour (EGP)'**
  String get pricePerHour;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter the price'**
  String get enterPrice;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @allowsHalfCourt.
  ///
  /// In en, this message translates to:
  /// **'Half court bookings'**
  String get allowsHalfCourt;

  /// No description provided for @halfCourtPrice.
  ///
  /// In en, this message translates to:
  /// **'Half court price per hour (EGP)'**
  String get halfCourtPrice;

  /// No description provided for @courtSaved.
  ///
  /// In en, this message translates to:
  /// **'Court saved'**
  String get courtSaved;

  /// No description provided for @courtDeleted.
  ///
  /// In en, this message translates to:
  /// **'Court deleted'**
  String get courtDeleted;

  /// No description provided for @deleteCourt.
  ///
  /// In en, this message translates to:
  /// **'Delete court'**
  String get deleteCourt;

  /// No description provided for @deleteCourtBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this court? Its upcoming bookings must be cancelled first.'**
  String get deleteCourtBody;

  /// No description provided for @courtActive.
  ///
  /// In en, this message translates to:
  /// **'Open for booking'**
  String get courtActive;

  /// No description provided for @priceRules.
  ///
  /// In en, this message translates to:
  /// **'Price rules'**
  String get priceRules;

  /// No description provided for @priceRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Different prices for certain days and hours'**
  String get priceRulesHint;

  /// No description provided for @addRule.
  ///
  /// In en, this message translates to:
  /// **'Add a rule'**
  String get addRule;

  /// No description provided for @anyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get anyDay;

  /// No description provided for @ruleFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get ruleFrom;

  /// No description provided for @ruleTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get ruleTo;

  /// No description provided for @slotsAndClosing.
  ///
  /// In en, this message translates to:
  /// **'Close times'**
  String get slotsAndClosing;

  /// No description provided for @slotsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a time to close it for booking, tap again to open it'**
  String get slotsHint;

  /// No description provided for @slotBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get slotBooked;

  /// No description provided for @pricesSaved.
  ///
  /// In en, this message translates to:
  /// **'Prices saved'**
  String get pricesSaved;

  /// No description provided for @noCourts.
  ///
  /// In en, this message translates to:
  /// **'No courts yet'**
  String get noCourts;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @clubOpen.
  ///
  /// In en, this message translates to:
  /// **'Club open for booking'**
  String get clubOpen;

  /// No description provided for @editClubInfo.
  ///
  /// In en, this message translates to:
  /// **'Club details'**
  String get editClubInfo;

  /// No description provided for @clubSaved.
  ///
  /// In en, this message translates to:
  /// **'Club saved'**
  String get clubSaved;

  /// No description provided for @hoursSaved.
  ///
  /// In en, this message translates to:
  /// **'Hours saved'**
  String get hoursSaved;

  /// No description provided for @mapUrl.
  ///
  /// In en, this message translates to:
  /// **'Map link (optional)'**
  String get mapUrl;

  /// No description provided for @clubPhone.
  ///
  /// In en, this message translates to:
  /// **'Club phone'**
  String get clubPhone;

  /// No description provided for @clubEmail.
  ///
  /// In en, this message translates to:
  /// **'Club email (optional)'**
  String get clubEmail;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change logo'**
  String get changeLogo;

  /// No description provided for @changeCover.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get changeCover;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get photoUpdated;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @subNone.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get subNone;

  /// No description provided for @subActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subActive;

  /// No description provided for @subGrace.
  ///
  /// In en, this message translates to:
  /// **'Grace period - renew now'**
  String get subGrace;

  /// No description provided for @subExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get subExpired;

  /// No description provided for @subPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get subPlan;

  /// No description provided for @subEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get subEnds;

  /// No description provided for @subCourts.
  ///
  /// In en, this message translates to:
  /// **'{used} of {max} courts'**
  String subCourts(int used, int max);

  /// No description provided for @renewNow.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renewNow;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeNow;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get choosePlan;

  /// No description provided for @planDetails.
  ///
  /// In en, this message translates to:
  /// **'{price} EGP · {courts} courts · {days} days'**
  String planDetails(String price, int courts, int days);

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @noStaff.
  ///
  /// In en, this message translates to:
  /// **'No staff yet'**
  String get noStaff;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add a staff member'**
  String get addStaff;

  /// No description provided for @firstName2.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName2;

  /// No description provided for @staffPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get staffPermissions;

  /// No description provided for @staffCourts.
  ///
  /// In en, this message translates to:
  /// **'Courts (none selected = all)'**
  String get staffCourts;

  /// No description provided for @staffAdded.
  ///
  /// In en, this message translates to:
  /// **'Staff member added'**
  String get staffAdded;

  /// No description provided for @staffRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get staffRemoved;

  /// No description provided for @removeStaff.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeStaff;

  /// No description provided for @activateStaff.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activateStaff;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordReset;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLog;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivity;

  /// No description provided for @permManageBookings.
  ///
  /// In en, this message translates to:
  /// **'Manage bookings'**
  String get permManageBookings;

  /// No description provided for @permManualBookings.
  ///
  /// In en, this message translates to:
  /// **'Manual bookings'**
  String get permManualBookings;

  /// No description provided for @permViewReports.
  ///
  /// In en, this message translates to:
  /// **'View reports'**
  String get permViewReports;

  /// No description provided for @permCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get permCheckIn;

  /// No description provided for @permManageSlots.
  ///
  /// In en, this message translates to:
  /// **'Close times'**
  String get permManageSlots;

  /// No description provided for @permRatePlayers.
  ///
  /// In en, this message translates to:
  /// **'Rate players'**
  String get permRatePlayers;

  /// No description provided for @permTournamentResults.
  ///
  /// In en, this message translates to:
  /// **'Tournament results'**
  String get permTournamentResults;

  /// No description provided for @permEditCourts.
  ///
  /// In en, this message translates to:
  /// **'Edit courts'**
  String get permEditCourts;

  /// No description provided for @permManageTournaments.
  ///
  /// In en, this message translates to:
  /// **'Manage tournaments'**
  String get permManageTournaments;

  /// No description provided for @createTournament.
  ///
  /// In en, this message translates to:
  /// **'New tournament'**
  String get createTournament;

  /// No description provided for @tournamentName.
  ///
  /// In en, this message translates to:
  /// **'Tournament name'**
  String get tournamentName;

  /// No description provided for @enterTournamentName.
  ///
  /// In en, this message translates to:
  /// **'Enter the tournament name'**
  String get enterTournamentName;

  /// No description provided for @rulesField.
  ///
  /// In en, this message translates to:
  /// **'Rules (optional)'**
  String get rulesField;

  /// No description provided for @prizesField.
  ///
  /// In en, this message translates to:
  /// **'Prizes (optional)'**
  String get prizesField;

  /// No description provided for @individualSwitch.
  ///
  /// In en, this message translates to:
  /// **'Individual (one player per entry)'**
  String get individualSwitch;

  /// No description provided for @playersPerTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Players per team'**
  String get playersPerTeamLabel;

  /// No description provided for @substitutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Substitutes per team'**
  String get substitutesLabel;

  /// No description provided for @maxTeamsLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum teams'**
  String get maxTeamsLabel;

  /// No description provided for @groupsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of groups'**
  String get groupsCountLabel;

  /// No description provided for @qualifiersLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualifiers per group'**
  String get qualifiersLabel;

  /// No description provided for @registrationCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration closes'**
  String get registrationCloseLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDateLabel;

  /// No description provided for @dailyStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily start'**
  String get dailyStartLabel;

  /// No description provided for @dailyEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily end'**
  String get dailyEndLabel;

  /// No description provided for @matchMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Match length'**
  String get matchMinutesLabel;

  /// No description provided for @pickCourts.
  ///
  /// In en, this message translates to:
  /// **'Courts used'**
  String get pickCourts;

  /// No description provided for @tournamentCreated.
  ///
  /// In en, this message translates to:
  /// **'Tournament created'**
  String get tournamentCreated;

  /// No description provided for @publishTournament.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishTournament;

  /// No description provided for @closeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Close registration'**
  String get closeRegistration;

  /// No description provided for @drawTournament.
  ///
  /// In en, this message translates to:
  /// **'Draw and schedule'**
  String get drawTournament;

  /// No description provided for @cancelTournament.
  ///
  /// In en, this message translates to:
  /// **'Cancel tournament'**
  String get cancelTournament;

  /// No description provided for @cancelTournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this tournament?'**
  String get cancelTournamentTitle;

  /// No description provided for @cancelReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get cancelReasonRequired;

  /// No description provided for @tournamentActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tournamentActionDone;

  /// No description provided for @approveTeam.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveTeam;

  /// No description provided for @rejectTeam.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectTeam;

  /// No description provided for @rejectTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this team'**
  String get rejectTeamTitle;

  /// No description provided for @noManagedTournaments.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created a tournament yet'**
  String get noManagedTournaments;

  /// No description provided for @enterResult.
  ///
  /// In en, this message translates to:
  /// **'Enter result'**
  String get enterResult;

  /// No description provided for @homeScore.
  ///
  /// In en, this message translates to:
  /// **'Home score'**
  String get homeScore;

  /// No description provided for @awayScore.
  ///
  /// In en, this message translates to:
  /// **'Away score'**
  String get awayScore;

  /// No description provided for @winnerOnDraw.
  ///
  /// In en, this message translates to:
  /// **'Winner (needed on a draw)'**
  String get winnerOnDraw;

  /// No description provided for @resultSaved.
  ///
  /// In en, this message translates to:
  /// **'Result saved'**
  String get resultSaved;

  /// No description provided for @pickPoster.
  ///
  /// In en, this message translates to:
  /// **'Change poster'**
  String get pickPoster;

  /// No description provided for @teamsPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get teamsPending;

  /// No description provided for @mustPickCourt.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one court'**
  String get mustPickCourt;

  /// No description provided for @recurringBooking.
  ///
  /// In en, this message translates to:
  /// **'Book every week'**
  String get recurringBooking;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly booking'**
  String get recurringTitle;

  /// No description provided for @weeksCount.
  ///
  /// In en, this message translates to:
  /// **'Number of weeks'**
  String get weeksCount;

  /// No description provided for @firstDay.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get firstDay;

  /// No description provided for @skipUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Skip weeks that are taken'**
  String get skipUnavailable;

  /// No description provided for @previewWeeks.
  ///
  /// In en, this message translates to:
  /// **'Check the weeks'**
  String get previewWeeks;

  /// No description provided for @weekAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get weekAvailable;

  /// No description provided for @weekTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get weekTaken;

  /// No description provided for @availableWeeksTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks available · total {price} EGP'**
  String availableWeeksTotal(int count, String price);

  /// No description provided for @confirmRecurring.
  ///
  /// In en, this message translates to:
  /// **'Book the available weeks'**
  String get confirmRecurring;

  /// No description provided for @recurringCreated.
  ///
  /// In en, this message translates to:
  /// **'Weekly booking created'**
  String get recurringCreated;

  /// No description provided for @myRecurring.
  ///
  /// In en, this message translates to:
  /// **'Weekly bookings'**
  String get myRecurring;

  /// No description provided for @noRecurring.
  ///
  /// In en, this message translates to:
  /// **'No weekly bookings'**
  String get noRecurring;

  /// No description provided for @everyWeekDay.
  ///
  /// In en, this message translates to:
  /// **'Every {day}'**
  String everyWeekDay(String day);

  /// No description provided for @weeksOf.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks from {day}'**
  String weeksOf(int count, String day);

  /// No description provided for @cancelRecurring.
  ///
  /// In en, this message translates to:
  /// **'Cancel all'**
  String get cancelRecurring;

  /// No description provided for @recurringCancelled.
  ///
  /// In en, this message translates to:
  /// **'Weekly booking cancelled'**
  String get recurringCancelled;

  /// No description provided for @tabWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get tabWeekly;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeat every week'**
  String get repeatWeekly;

  /// No description provided for @recurringStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the club'**
  String get recurringStatusPending;

  /// No description provided for @recurringStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get recurringStatusConfirmed;

  /// No description provided for @recurringStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get recurringStatusRejected;

  /// No description provided for @recurringStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get recurringStatusCancelled;

  /// No description provided for @recurringStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get recurringStatusExpired;

  /// No description provided for @clubPhotos.
  ///
  /// In en, this message translates to:
  /// **'Club photos'**
  String get clubPhotos;

  /// No description provided for @courtPhotos.
  ///
  /// In en, this message translates to:
  /// **'Court photos'**
  String get courtPhotos;

  /// No description provided for @addPhotos2.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos2;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhoto;

  /// No description provided for @setCover.
  ///
  /// In en, this message translates to:
  /// **'Set as cover'**
  String get setCover;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photos added'**
  String get photoAdded;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// No description provided for @coverSet.
  ///
  /// In en, this message translates to:
  /// **'Cover updated'**
  String get coverSet;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotos;

  /// No description provided for @courtPhotosMenu.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get courtPhotosMenu;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @reportPeriod7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get reportPeriod7;

  /// No description provided for @reportPeriod30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get reportPeriod30;

  /// No description provided for @reportPeriod90.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get reportPeriod90;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @bookingsTotal.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTotal;

  /// No description provided for @noShowRate.
  ///
  /// In en, this message translates to:
  /// **'No-show rate'**
  String get noShowRate;

  /// No description provided for @occupancy.
  ///
  /// In en, this message translates to:
  /// **'Court occupancy'**
  String get occupancy;

  /// No description provided for @peakHours.
  ///
  /// In en, this message translates to:
  /// **'Busiest times'**
  String get peakHours;

  /// No description provided for @bySource.
  ///
  /// In en, this message translates to:
  /// **'Where bookings come from'**
  String get bySource;

  /// No description provided for @topCustomers.
  ///
  /// In en, this message translates to:
  /// **'Top customers'**
  String get topCustomers;

  /// No description provided for @ratingsSummary.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratingsSummary;

  /// No description provided for @sourceApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sourceApp;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sourceManual;

  /// No description provided for @hoursBooked.
  ///
  /// In en, this message translates to:
  /// **'{booked} of {available} h'**
  String hoursBooked(String booked, String available);

  /// No description provided for @rescheduleMatch.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get rescheduleMatch;

  /// No description provided for @rescheduled.
  ///
  /// In en, this message translates to:
  /// **'Match rescheduled'**
  String get rescheduled;

  /// No description provided for @pickCourt.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get pickCourt;

  /// No description provided for @becomeOwner.
  ///
  /// In en, this message translates to:
  /// **'Own a club? Join Sportiva'**
  String get becomeOwner;

  /// No description provided for @membershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Club owner request'**
  String get membershipTitle;

  /// No description provided for @membershipIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your club. The Sportiva team reviews your request and sets your club up.'**
  String get membershipIntro;

  /// No description provided for @applicantName.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get applicantName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @clubNameField.
  ///
  /// In en, this message translates to:
  /// **'Club name'**
  String get clubNameField;

  /// No description provided for @enterClubName.
  ///
  /// In en, this message translates to:
  /// **'Enter the club name'**
  String get enterClubName;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, area'**
  String get addressHint;

  /// No description provided for @locationUrl.
  ///
  /// In en, this message translates to:
  /// **'Map link (optional)'**
  String get locationUrl;

  /// No description provided for @attachFiles.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos of the club'**
  String get attachFiles;

  /// No description provided for @attachHint.
  ///
  /// In en, this message translates to:
  /// **'Up to {images} photos and {videos} videos'**
  String attachHint(int images, int videos);

  /// No description provided for @addVideoShort.
  ///
  /// In en, this message translates to:
  /// **'Add video'**
  String get addVideoShort;

  /// No description provided for @tooManyVideos.
  ///
  /// In en, this message translates to:
  /// **'At most {count} videos'**
  String tooManyVideos(int count);

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get submitRequest;

  /// No description provided for @requestSentMembership.
  ///
  /// In en, this message translates to:
  /// **'Your request was sent'**
  String get requestSentMembership;

  /// No description provided for @membershipPending.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get membershipPending;

  /// No description provided for @membershipApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get membershipApproved;

  /// No description provided for @membershipRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get membershipRejected;

  /// No description provided for @membershipPendingBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you as soon as the team reviews it.'**
  String get membershipPendingBody;

  /// No description provided for @membershipApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is now a club owner account. The team will link your club shortly.'**
  String get membershipApprovedBody;

  /// No description provided for @membershipRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'You can send a new request.'**
  String get membershipRejectedBody;

  /// No description provided for @rejectionReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rejectionReasonLabel;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'Send a new request'**
  String get newRequest;

  /// No description provided for @mediaProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get mediaProcessing;

  /// No description provided for @mediaFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get mediaFailed;

  /// No description provided for @addMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get addMoreFiles;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFile;

  /// No description provided for @yourRequest.
  ///
  /// In en, this message translates to:
  /// **'Your request'**
  String get yourRequest;

  /// No description provided for @preferredSports.
  ///
  /// In en, this message translates to:
  /// **'Favorite sports'**
  String get preferredSports;

  /// No description provided for @preferredSportsHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the sports you play'**
  String get preferredSportsHint;

  /// No description provided for @preferredSportsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get preferredSportsSaved;

  /// No description provided for @matchOnCourt.
  ///
  /// In en, this message translates to:
  /// **'Match on a club court'**
  String get matchOnCourt;

  /// No description provided for @matchOnOutside.
  ///
  /// In en, this message translates to:
  /// **'Match somewhere else'**
  String get matchOnOutside;

  /// No description provided for @pickClubCourt.
  ///
  /// In en, this message translates to:
  /// **'Pick the court and time from the club page, then open the match from your booking.'**
  String get pickClubCourt;

  /// No description provided for @openAsMatch.
  ///
  /// In en, this message translates to:
  /// **'Open it as a match'**
  String get openAsMatch;

  /// No description provided for @openAsMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Players can ask to join once the club confirms'**
  String get openAsMatchHint;

  /// No description provided for @openMatchNow.
  ///
  /// In en, this message translates to:
  /// **'Book and open the match'**
  String get openMatchNow;

  /// No description provided for @pickCourtTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a court'**
  String get pickCourtTitle;

  /// No description provided for @pickCourtButton.
  ///
  /// In en, this message translates to:
  /// **'Pick a court'**
  String get pickCourtButton;

  /// No description provided for @chooseCourtForMatch.
  ///
  /// In en, this message translates to:
  /// **'The match is held on a club court: pick the court, the day and the time.'**
  String get chooseCourtForMatch;

  /// No description provided for @matchStartedOnCourt.
  ///
  /// In en, this message translates to:
  /// **'Your court booking is in; the match opens when the club confirms'**
  String get matchStartedOnCourt;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سبورتيفا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterEmail => 'اكتب بريدك الإلكتروني';

  @override
  String get password => 'كلمة السر';

  @override
  String get enterPassword => 'اكتب كلمة السر';

  @override
  String get rePassword => 'تأكيد كلمة السر';

  @override
  String get retypePassword => 'اكتب كلمة السر تاني';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get enterFirstName => 'اكتب اسمك الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get enterLastName => 'اكتب اسم العائلة';

  @override
  String get forgotPassword => 'نسيت كلمة السر؟';

  @override
  String get signIn => 'دخول';

  @override
  String get noAccount => 'معندكش حساب؟';

  @override
  String get haveAccount => 'عندك حساب؟';

  @override
  String get signUpLink => 'سجّل دلوقتي';

  @override
  String get signInLink => 'ادخل';

  @override
  String get orLoginWith => 'أو سجّل الدخول بـ';

  @override
  String get orSignUpWith => 'أو أنشئ حساب بـ';

  @override
  String get checkYourEmail => 'شوف إيميلك';

  @override
  String get codeSentTo => 'بعتنا كود على';

  @override
  String get enterCodeHint => 'اكتب الكود المكوّن من 6 أرقام اللي في الإيميل';

  @override
  String get verifyCode => 'تأكيد الكود';

  @override
  String get noEmailYet => 'لسه ما وصلكش الإيميل؟';

  @override
  String get resendEmail => 'ابعت تاني';

  @override
  String resendIn(int seconds) {
    return 'ابعت تاني بعد $seconds ثانية';
  }

  @override
  String get forgotPasswordTitle => 'نسيت كلمة السر';

  @override
  String get forgotPasswordHint => 'اكتب بريدك الإلكتروني عشان نغيّر كلمة السر';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get setNewPassword => 'كلمة سر جديدة';

  @override
  String get setNewPasswordHint => 'اختار كلمة سر جديدة ومختلفة عن القديمة عشان أمان حسابك';

  @override
  String get confirmPassword => 'تأكيد كلمة السر';

  @override
  String get updatePassword => 'تحديث كلمة السر';

  @override
  String get fieldRequired => 'الحقل ده مطلوب';

  @override
  String get invalidEmail => 'اكتب بريد إلكتروني صحيح';

  @override
  String get passwordRule => '8 حروف على الأقل وفيها رقم وحرف كبير وحرف صغير ورمز';

  @override
  String get passwordsDontMatch => 'كلمتين السر مش متطابقين';

  @override
  String get nameTooShort => '3 حروف على الأقل';

  @override
  String get invalidCode => 'اكتب الكود المكوّن من 6 أرقام';

  @override
  String get networkError => 'مش قادرين نوصل للسيرفر. اتأكد من الإنترنت وجرّب تاني.';

  @override
  String get unknownError => 'حصلت مشكلة. جرّب تاني.';

  @override
  String get googleNotConfigured => 'الدخول بجوجل لسه مش متظبط.';

  @override
  String get googleSignInFailed => 'الدخول بجوجل فشل. جرّب تاني.';

  @override
  String get emailConfirmed => 'الإيميل اتأكد. تقدر تدخل دلوقتي.';

  @override
  String get passwordUpdated => 'كلمة السر اتحدّثت. تقدر تدخل دلوقتي.';

  @override
  String get codeResent => 'لو الإيميل محتاج كود، اتبعتله كود جديد.';

  @override
  String get accountCreated => 'الحساب اتعمل. شوف إيميلك علشان الكود.';

  @override
  String get emailNotConfirmedHint => 'إيميلك لسه مش مأكّد. بعتنالك كود.';

  @override
  String welcome(String name) {
    return 'أهلاً $name';
  }

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get switchLanguage => 'English';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMatches => 'ماتشات';

  @override
  String get navSocial => 'المجتمع';

  @override
  String get navBookings => 'حجوزاتي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get retry => 'حاول تاني';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get noNotifications => 'مفيش إشعارات لسه';

  @override
  String get delete => 'مسح';

  @override
  String get nothingHere => 'مفيش حاجة هنا لسه';

  @override
  String get timeNow => 'دلوقتي';

  @override
  String timeMinutes(int count) {
    return 'من $count د';
  }

  @override
  String timeHours(int count) {
    return 'من $count س';
  }

  @override
  String timeDays(int count) {
    return 'من $count يوم';
  }

  @override
  String get language => 'اللغة';

  @override
  String get locationTitle => 'اعرف الملاعب اللي حواليك';

  @override
  String get locationBody => 'اسمح بالوصول للموقع عشان نعرضلك أقرب الملاعب ونقولك كل ملعب بعيد عنك قد إيه.';

  @override
  String get allowLocation => 'السماح بالموقع';

  @override
  String get notNow => 'مش دلوقتي';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get turnOnLocation => 'شغّل الموقع';

  @override
  String get locationDeniedForever => 'الوصول للموقع متقفل للتطبيق. فعّله من إعدادات التليفون.';

  @override
  String get locationServiceOff => 'الموقع مقفول على تليفونك.';

  @override
  String helloUser(String name) {
    return 'أهلاً $name';
  }

  @override
  String get courtsNearYou => 'ملاعب قريبة منك';

  @override
  String courtsOfSport(String sport) {
    return 'ملاعب $sport';
  }

  @override
  String get noCourtsForSport => 'مفيش ملاعب للرياضة دي لسه';

  @override
  String get topRatedClubs => 'الأندية الأعلى تقييماً';

  @override
  String get noClubsYet => 'مفيش أندية لسه';

  @override
  String get chooseSport => 'اختار رياضة';

  @override
  String get sportFootball => 'كرة قدم';

  @override
  String get sportPadel => 'بادل';

  @override
  String get sportBasketball => 'سلة';

  @override
  String get sportTennis => 'تنس';

  @override
  String get sportVolleyball => 'طائرة';

  @override
  String get sportOther => 'أخرى';

  @override
  String perHour(String price) {
    return '$price ج / ساعة';
  }

  @override
  String courtsCount(int count) {
    return '$count ملاعب';
  }

  @override
  String get courts => 'الملاعب';

  @override
  String get workingHours => 'مواعيد العمل';

  @override
  String get reviews => 'التقييمات';

  @override
  String get noReviews => 'مفيش تقييمات لسه';

  @override
  String get address => 'العنوان';

  @override
  String get callClub => 'اتصال';

  @override
  String get openInMaps => 'افتح في الخرائط';

  @override
  String get closed => 'مقفول';

  @override
  String get allDay => 'مفتوح';

  @override
  String get chooseDay => 'اختار اليوم';

  @override
  String get duration => 'المدة';

  @override
  String get courtPart => 'الملعب';

  @override
  String get fullCourt => 'ملعب كامل';

  @override
  String get halfA => 'النص الأول';

  @override
  String get halfB => 'النص التاني';

  @override
  String get playFormat => 'نظام اللعب';

  @override
  String get singles => 'فردي';

  @override
  String get doubles => 'زوجي';

  @override
  String get chooseTime => 'اختار الميعاد';

  @override
  String get noTimesAvailable => 'مفيش مواعيد فاضية بالاختيار ده';

  @override
  String minutesLabel(int minutes) {
    return '$minutes د';
  }

  @override
  String priceTotal(String price) {
    return '$price ج';
  }

  @override
  String get total => 'الإجمالي';

  @override
  String get bookNow => 'احجز دلوقتي';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get bookingSummary => 'ملخص الحجز';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get selectTimeFirst => 'اختار ميعاد عشان تكمّل';

  @override
  String get bookingConfirmed => 'حجزك اتأكد';

  @override
  String get bookingRequested => 'الطلب اتبعت. النادي هيأكده قريب.';

  @override
  String get upcoming => 'الجاية';

  @override
  String get past => 'السابقة';

  @override
  String get noBookings => 'مفيش حجوزات لسه';

  @override
  String bookingCode(String code) {
    return 'حجز $code';
  }

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get cancelBookingBody => 'عايز تلغي الحجز ده؟';

  @override
  String get cancelReasonHint => 'السبب (اختياري)';

  @override
  String get keepBooking => 'سيبه';

  @override
  String get bookingCancelled => 'الحجز اتلغى';

  @override
  String get bookingDetails => 'تفاصيل الحجز';

  @override
  String get court => 'الملعب';

  @override
  String get club => 'النادي';

  @override
  String get dateLabel => 'اليوم';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get status => 'الحالة';

  @override
  String get waitingForClub => 'مستني تأكيد النادي';

  @override
  String get statusPending => 'مستني';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusCompleted => 'اتلعب';

  @override
  String get statusNoShow => 'ماجاش';

  @override
  String get statusExpired => 'انتهى';

  @override
  String get reason => 'السبب';

  @override
  String timeRange(String from, String to) {
    return '$from - $to';
  }

  @override
  String get openMatches => 'ماتشات مفتوحة';

  @override
  String get myMatches => 'ماتشاتي';

  @override
  String get allSports => 'الكل';

  @override
  String get noOpenMatches => 'مفيش ماتشات مفتوحة دلوقتي';

  @override
  String get noMyMatches => 'معندكش ماتشات لسه';

  @override
  String get createMatch => 'ابدأ ماتش';

  @override
  String get matchDetails => 'تفاصيل الماتش';

  @override
  String get organizer => 'المنظّم';

  @override
  String get players => 'اللاعيبة';

  @override
  String playersCount(int joined, int needed) {
    return '$joined/$needed لاعيبة';
  }

  @override
  String spotsLeft(int count) {
    return 'فاضل $count أماكن';
  }

  @override
  String get requestToJoin => 'اطلب الانضمام';

  @override
  String get requestSent => 'الطلب اتبعت';

  @override
  String get leaveMatch => 'اطلع من الماتش';

  @override
  String get cancelRequest => 'الغي الطلب';

  @override
  String get cancelMatch => 'الغي الماتش';

  @override
  String get cancelMatchBody => 'تلغي الماتش ده للكل؟';

  @override
  String get matchCancelled => 'الماتش اتلغى';

  @override
  String get joinRequests => 'طلبات الانضمام';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get noRequests => 'مفيش طلبات معلّقة';

  @override
  String get openChat => 'شات الماتش';

  @override
  String get matchStatusOpen => 'مفتوح';

  @override
  String get matchStatusFull => 'كامل';

  @override
  String get matchStatusInProgress => 'شغّال';

  @override
  String get matchStatusCompleted => 'خلص';

  @override
  String get matchStatusCancelled => 'ملغي';

  @override
  String get waitingClubConfirm => 'مستني النادي يأكد الحجز';

  @override
  String get sport => 'الرياضة';

  @override
  String get playersNeeded => 'عدد اللاعيبة المطلوب';

  @override
  String get placeName => 'اسم المكان';

  @override
  String get enterPlaceName => 'اكتب اسم المكان';

  @override
  String get city => 'المدينة';

  @override
  String get enterCity => 'اكتب المدينة';

  @override
  String get governorate => 'المحافظة';

  @override
  String get note => 'ملاحظة (اختياري)';

  @override
  String get enterNote => 'أي حاجة اللاعيبة لازم يعرفوها';

  @override
  String get pickDate => 'اختار اليوم';

  @override
  String get pickTime => 'اختار الميعاد';

  @override
  String get matchCreated => 'الماتش اتعمل';

  @override
  String get openMatchFromBooking => 'افتح الحجز ده للاعيبة';

  @override
  String get openMatch => 'افتح الماتش';

  @override
  String get playersToFind => 'محتاج كام لاعب؟';

  @override
  String get typeMessage => 'اكتب رسالة';

  @override
  String get noMessages => 'مفيش رسايل لسه';

  @override
  String get send => 'ابعت';

  @override
  String playerRating(String rating) {
    return '$rating';
  }

  @override
  String get youAreOrganizer => 'إنت المنظّم';

  @override
  String get requestPending => 'طلبك معلّق';

  @override
  String get youAreIn => 'إنت في الماتش ده';

  @override
  String get wholeDayHint => 'الميعاد على الساعة أو النص';

  @override
  String get feed => 'بتتابعهم';

  @override
  String get explore => 'استكشف';

  @override
  String get reels => 'لك';

  @override
  String get searchHint => 'ابحث عن نادي أو ملعب';

  @override
  String get noPosts => 'مفيش بوستات لسه';

  @override
  String get newPostsAvailable => 'فيه بوستات جديدة';

  @override
  String get newPost => 'بوست جديد';

  @override
  String get whatsOnYourMind => 'بتفكر في إيه؟';

  @override
  String get addPhotos => 'صور';

  @override
  String get addVideo => 'فيديو';

  @override
  String get publish => 'نشر';

  @override
  String get postProcessing => 'بوستك بيتجهز وهيظهر أول ما يخلص.';

  @override
  String get postPublished => 'البوست اتنشر';

  @override
  String get postFailed => 'البوست ماتنشرش';

  @override
  String get postEmpty => 'اكتب حاجة أو ضيف صورة أو فيديو';

  @override
  String maxPhotos(int count) {
    return 'أقصى عدد صور $count';
  }

  @override
  String get videoTooLarge => 'الفيديو كبير (100 ميجا بالكتير)';

  @override
  String likes(int count) {
    return '$count إعجاب';
  }

  @override
  String get comments => 'التعليقات';

  @override
  String commentsCount(int count) {
    return '$count تعليق';
  }

  @override
  String get writeComment => 'اكتب تعليق';

  @override
  String replyingTo(String name) {
    return 'رد على $name';
  }

  @override
  String get reply => 'رد';

  @override
  String replies(int count) {
    return '$count ردود';
  }

  @override
  String get hideReplies => 'إخفاء الردود';

  @override
  String get noComments => 'مفيش تعليقات لسه';

  @override
  String get deletePost => 'مسح البوست';

  @override
  String get deletePostBody => 'تمسح البوست ده؟';

  @override
  String get editPost => 'تعديل البوست';

  @override
  String get save => 'حفظ';

  @override
  String get report => 'إبلاغ';

  @override
  String get reportTitle => 'ليه بتبلّغ عن ده؟';

  @override
  String get reportSent => 'شكرًا، هنراجعه';

  @override
  String get reasonSexualContent => 'محتوى جنسي';

  @override
  String get reasonViolence => 'عنف';

  @override
  String get reasonHarassment => 'مضايقة';

  @override
  String get reasonSpam => 'سبام';

  @override
  String get reasonMisinformation => 'معلومات مضللة';

  @override
  String get reasonImpersonation => 'انتحال شخصية';

  @override
  String get reasonOther => 'حاجة تانية';

  @override
  String get block => 'حظر';

  @override
  String get unblock => 'إلغاء الحظر';

  @override
  String get blockBody => 'مش هيقدر يشوف بوستاتك ولا يبعتلك رسايل.';

  @override
  String get blocked => 'اتحظر';

  @override
  String get follow => 'تابع';

  @override
  String get following => 'بتتابعه';

  @override
  String get followBack => 'تابعه كمان';

  @override
  String get followers => 'المتابعين';

  @override
  String get followingLabel => 'بيتابع';

  @override
  String get postsLabel => 'بوستات';

  @override
  String get message => 'رسالة';

  @override
  String get editProfile => 'تعديل البروفايل';

  @override
  String get bio => 'نبذة';

  @override
  String get enterBio => 'عرّف الناس بنفسك';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get profileSaved => 'البروفايل اتحفظ';

  @override
  String get online => 'أونلاين';

  @override
  String get messages => 'الرسايل';

  @override
  String get noConversations => 'مفيش محادثات لسه';

  @override
  String get noPeople => 'مفيش ناس لسه';

  @override
  String get you => 'إنت';

  @override
  String get viewReel => 'ريلز';

  @override
  String get noReels => 'مفيش ريلز لسه';

  @override
  String get videoUnavailable => 'الفيديو مش متاح';

  @override
  String get searchPeople => 'ناس';

  @override
  String get searchClubs => 'أندية';

  @override
  String get searchPosts => 'بوستات';

  @override
  String get typeToSearch => 'اكتب عشان تدوّر';

  @override
  String get noResults => 'مفيش نتايج';

  @override
  String get viewProfile => 'عرض البروفايل';

  @override
  String get videoPicked => 'الفيديو اتختار';

  @override
  String get removeVideo => 'شيل الفيديو';

  @override
  String get showNewPosts => 'اعرض البوستات الجديدة';

  @override
  String get followersOf => 'المتابعين';

  @override
  String get followingOf => 'بيتابع';

  @override
  String get blockedProfile => 'إنت حاظر الشخص ده';

  @override
  String get sendFirstMessage => 'ابدأ بالسلام';

  @override
  String get tournaments => 'البطولات';

  @override
  String get tournamentsSubtitle => 'اشترك في بطولة أو تابع واحدة';

  @override
  String get noTournaments => 'مفيش بطولات دلوقتي';

  @override
  String get tournamentDetails => 'البطولة';

  @override
  String get tabInfo => 'معلومات';

  @override
  String get tabTeams => 'الفرق';

  @override
  String get tabMatches => 'الماتشات';

  @override
  String get tabStandings => 'الترتيب';

  @override
  String get tournamentRegistrationOpen => 'التسجيل مفتوح';

  @override
  String get tournamentRegistrationClosed => 'التسجيل اتقفل';

  @override
  String get tournamentInProgress => 'شغّالة';

  @override
  String get tournamentCompleted => 'خلصت';

  @override
  String get tournamentCancelled => 'ملغية';

  @override
  String get tournamentDraft => 'مسودة';

  @override
  String get formatKnockout => 'خروج المغلوب';

  @override
  String get formatLeague => 'دوري';

  @override
  String get formatGroupsKnockout => 'مجموعات + خروج المغلوب';

  @override
  String get individualTournament => 'فردي';

  @override
  String teamsCount(int joined, int max) {
    return '$joined/$max فريق';
  }

  @override
  String get entryFee => 'رسوم الاشتراك';

  @override
  String get free => 'مجاني';

  @override
  String feeAmount(String amount) {
    return '$amount جنيه';
  }

  @override
  String get registrationCloses => 'التسجيل بيقفل';

  @override
  String get startsOn => 'بتبدأ';

  @override
  String get endsOn => 'بتخلص';

  @override
  String get tournamentFormat => 'النظام';

  @override
  String get teamSize => 'لاعيبة الفريق';

  @override
  String teamSizeValue(int players, int subs) {
    return '$players + $subs احتياطي';
  }

  @override
  String get matchLength => 'مدة الماتش';

  @override
  String get tournamentCourts => 'الملاعب';

  @override
  String get description => 'الوصف';

  @override
  String get rules => 'القواعد';

  @override
  String get prizes => 'الجوايز';

  @override
  String get champion => 'البطل';

  @override
  String cancellationReason(String reason) {
    return 'اتلغت: $reason';
  }

  @override
  String get registerTeam => 'سجّل فريق';

  @override
  String get registerPlayer => 'اشترك في البطولة';

  @override
  String get myTeam => 'فريقي';

  @override
  String get teamName => 'اسم الفريق';

  @override
  String get enterTeamName => 'اكتب اسم الفريق';

  @override
  String get teamCreated => 'الفريق اتعمل';

  @override
  String get noTeams => 'مفيش فرق لسه';

  @override
  String get noMatchesYet => 'الجدول لسه مجهزش';

  @override
  String get noStandings => 'مفيش ترتيب لسه';

  @override
  String get stageLeague => 'الدوري';

  @override
  String stageGroup(int number) {
    return 'مجموعة $number';
  }

  @override
  String get stageKnockout => 'خروج المغلوب';

  @override
  String roundLabel(int number) {
    return 'الدور $number';
  }

  @override
  String get tbd => 'لسه هيتحدد';

  @override
  String get bye => 'إعفاء';

  @override
  String get matchWaiting => 'مستني';

  @override
  String get matchScheduled => 'متحدد';

  @override
  String get matchDone => 'خلص';

  @override
  String get matchCancelledShort => 'ملغي';

  @override
  String get colPlayed => 'لعب';

  @override
  String get colWon => 'فاز';

  @override
  String get colDrawn => 'تعادل';

  @override
  String get colLost => 'خسر';

  @override
  String get colGoalDiff => 'فارق';

  @override
  String get colPoints => 'نقاط';

  @override
  String groupNumber(int number) {
    return 'مجموعة $number';
  }

  @override
  String get teamStatusForming => 'بيتكوّن';

  @override
  String get teamStatusPendingPayment => 'مستني الدفع';

  @override
  String get teamStatusPendingApproval => 'مستني الموافقة';

  @override
  String get teamStatusApproved => 'متقبّل';

  @override
  String get teamStatusRejected => 'مرفوض';

  @override
  String get teamStatusWithdrawn => 'منسحب';

  @override
  String get teamStatusCancelled => 'ملغي';

  @override
  String rejectionReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get captain => 'الكابتن';

  @override
  String get substitute => 'احتياطي';

  @override
  String get memberInvited => 'مدعو';

  @override
  String get memberAccepted => 'انضم';

  @override
  String get memberDeclined => 'رفض';

  @override
  String get memberRemoved => 'اتشال';

  @override
  String get invitePlayer => 'ادعو لاعب';

  @override
  String get inviteAsSubstitute => 'كاحتياطي';

  @override
  String get inviteSent => 'الدعوة اتبعتت';

  @override
  String get removeMember => 'شيله من الفريق';

  @override
  String get payNow => 'ادفع رسوم الاشتراك';

  @override
  String get payWithCard => 'كارت';

  @override
  String get payWithWallet => 'محفظة موبايل';

  @override
  String get payHint => 'هتكمّل الدفع في المتصفح والفريق بيتحدّث لوحده.';

  @override
  String get withdrawTeam => 'انسحب بالفريق';

  @override
  String get withdrawBody => 'تسحب الفريق ده من البطولة؟';

  @override
  String get withdrawn => 'الفريق انسحب';

  @override
  String get myTeams => 'فرقي';

  @override
  String get invitations => 'الدعوات';

  @override
  String get noMyTeams => 'لسه مشتركتش في أي بطولة';

  @override
  String get noInvitations => 'مفيش دعوات';

  @override
  String invitedBy(String name) {
    return '$name دعاك';
  }

  @override
  String get decline => 'ارفض';

  @override
  String get invitationAccepted => 'انضممت للفريق';

  @override
  String get invitationDeclined => 'الدعوة اترفضت';

  @override
  String get searchPlayers => 'دوّر على لاعب';

  @override
  String get teamsAndInvitations => 'فرقي ودعواتي';

  @override
  String get allTournamentSports => 'كل الرياضات';

  @override
  String get openTournaments => 'التسجيل مفتوح';

  @override
  String get rateCourt => 'قيّم الملعب';

  @override
  String get ratePlayers => 'قيّم اللاعيبة';

  @override
  String get yourRating => 'تقييمك';

  @override
  String get commentOptional => 'تعليق (اختياري)';

  @override
  String get submitReview => 'ابعت التقييم';

  @override
  String get reviewSent => 'شكرًا على تقييمك';

  @override
  String get myReviews => 'تقييماتي';

  @override
  String get reviewsWritten => 'اللي عملتها';

  @override
  String get reviewsReceived => 'اللي جاتلي';

  @override
  String get reviewHiddenUntil => 'مخفي لحد ما فترة التقييم تخلص';

  @override
  String get deleteReview => 'مسح التقييم';

  @override
  String get reviewDeleted => 'التقييم اتمسح';

  @override
  String get rated => 'اتقيّم';

  @override
  String get tapToRate => 'اضغط على لاعب عشان تقيّمه';

  @override
  String get settings => 'الإعدادات';

  @override
  String get account => 'الحساب';

  @override
  String get phone => 'الموبايل';

  @override
  String get enterPhone => 'اكتب رقم موبايلك';

  @override
  String get savePhone => 'حفظ';

  @override
  String get phoneSaved => 'الرقم اتحفظ';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get inApp => 'جوه التطبيق';

  @override
  String get byEmail => 'بالإيميل';

  @override
  String get categoryBookings => 'الحجوزات والتقييمات';

  @override
  String get categoryPayments => 'المدفوعات والاشتراكات';

  @override
  String get categoryMatches => 'الماتشات';

  @override
  String get categorySocial => 'السوشيال والرسايل';

  @override
  String get categoryTournaments => 'البطولات';

  @override
  String get categoryAccount => 'الحساب والنظام';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get enterCurrentPassword => 'اكتب كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordChanged => 'كلمة المرور اتغيّرت';

  @override
  String get deleteAccount => 'امسح حسابي';

  @override
  String get deleteAccountBody => 'حسابك هيتقفل وبياناتك هتتمسح. ومش هتقدر ترجع فيها.';

  @override
  String get deleteAccountConfirm => 'امسح';

  @override
  String get deletionRequested => 'حسابك هيتمسح';

  @override
  String get manageClub => 'إدارة ناديي';

  @override
  String get invalidPhone => 'اكتب رقم موبايل مصري صحيح';

  @override
  String get ownerTitle => 'ناديي';

  @override
  String get ownerBookings => 'الحجوزات';

  @override
  String get ownerCourts => 'الملاعب';

  @override
  String get ownerTournaments => 'البطولات';

  @override
  String get ownerClub => 'النادي';

  @override
  String get tabPending => 'الطلبات';

  @override
  String get tabUpcoming => 'الجاية';

  @override
  String get tabPast => 'السابقة';

  @override
  String get noOwnerBookings => 'مفيش حجوزات هنا';

  @override
  String get confirmAction => 'تأكيد';

  @override
  String get rejectAction => 'رفض';

  @override
  String get rejectBookingTitle => 'رفض الحجز';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get cancelBookingAction => 'إلغاء الحجز';

  @override
  String get markCompleted => 'تم اللعب';

  @override
  String get markNoShow => 'ماجاش';

  @override
  String get ratePlayer => 'قيّم اللاعب';

  @override
  String get customer => 'العميل';

  @override
  String get walkInCustomer => 'عميل من الاستقبال';

  @override
  String get manualBooking => 'حجز جديد';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get customerPhone => 'موبايل العميل';

  @override
  String get customerEmail => 'إيميل العميل (اختياري)';

  @override
  String get selectCourt => 'الملعب';

  @override
  String get bookingCreated => 'الحجز اتعمل';

  @override
  String get bookingUpdated => 'تمام';

  @override
  String get playFormatLabel => 'نظام اللعب';

  @override
  String get courtPartLabel => 'جزء الملعب';

  @override
  String get callCustomer => 'اتصل';

  @override
  String needsReply(String time) {
    return 'رد قبل $time';
  }

  @override
  String get addCourt => 'ضيف ملعب';

  @override
  String get editCourt => 'تعديل الملعب';

  @override
  String get courtName => 'اسم الملعب';

  @override
  String get enterCourtName => 'اكتب اسم الملعب';

  @override
  String get confirmationMode => 'تأكيد الحجز';

  @override
  String get modeManual => 'أنا اللي أأكد كل حجز';

  @override
  String get modeAutomatic => 'تلقائي';

  @override
  String get responseTimeout => 'الرد خلال (دقيقة)';

  @override
  String get pricePerHour => 'سعر الساعة (جنيه)';

  @override
  String get enterPrice => 'اكتب السعر';

  @override
  String get invalidNumber => 'اكتب رقم صحيح';

  @override
  String get allowsHalfCourt => 'حجز نص ملعب';

  @override
  String get halfCourtPrice => 'سعر ساعة نص الملعب (جنيه)';

  @override
  String get courtSaved => 'الملعب اتحفظ';

  @override
  String get courtDeleted => 'الملعب اتمسح';

  @override
  String get deleteCourt => 'مسح الملعب';

  @override
  String get deleteCourtBody => 'تمسح الملعب ده؟ لازم تلغي حجوزاته الجاية الأول.';

  @override
  String get courtActive => 'مفتوح للحجز';

  @override
  String get priceRules => 'قواعد الأسعار';

  @override
  String get priceRulesHint => 'أسعار مختلفة لأيام وساعات معينة';

  @override
  String get addRule => 'ضيف قاعدة';

  @override
  String get anyDay => 'كل يوم';

  @override
  String get ruleFrom => 'من';

  @override
  String get ruleTo => 'إلى';

  @override
  String get slotsAndClosing => 'قفل المواعيد';

  @override
  String get slotsHint => 'اضغط على ميعاد عشان تقفله للحجز، واضغط تاني عشان تفتحه';

  @override
  String get slotBooked => 'محجوز';

  @override
  String get pricesSaved => 'الأسعار اتحفظت';

  @override
  String get noCourts => 'مفيش ملاعب لسه';

  @override
  String get weekdaySun => 'الأحد';

  @override
  String get weekdayMon => 'الاثنين';

  @override
  String get weekdayTue => 'الثلاثاء';

  @override
  String get weekdayWed => 'الأربعاء';

  @override
  String get weekdayThu => 'الخميس';

  @override
  String get weekdayFri => 'الجمعة';

  @override
  String get weekdaySat => 'السبت';

  @override
  String get clubOpen => 'النادي مفتوح للحجز';

  @override
  String get editClubInfo => 'بيانات النادي';

  @override
  String get clubSaved => 'النادي اتحفظ';

  @override
  String get hoursSaved => 'المواعيد اتحفظت';

  @override
  String get mapUrl => 'لينك الخريطة (اختياري)';

  @override
  String get clubPhone => 'موبايل النادي';

  @override
  String get clubEmail => 'إيميل النادي (اختياري)';

  @override
  String get changeLogo => 'تغيير اللوجو';

  @override
  String get changeCover => 'تغيير الغلاف';

  @override
  String get photoUpdated => 'الصورة اتغيّرت';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get subNone => 'مفيش اشتراك فعّال';

  @override
  String get subActive => 'فعّال';

  @override
  String get subGrace => 'فترة سماح - جدّد دلوقتي';

  @override
  String get subExpired => 'منتهي';

  @override
  String get subPlan => 'الباقة';

  @override
  String get subEnds => 'بينتهي';

  @override
  String subCourts(int used, int max) {
    return '$used من $max ملعب';
  }

  @override
  String get renewNow => 'جدّد';

  @override
  String get subscribeNow => 'اشترك';

  @override
  String get choosePlan => 'اختار باقة';

  @override
  String planDetails(String price, int courts, int days) {
    return '$price جنيه · $courts ملاعب · $days يوم';
  }

  @override
  String get staff => 'الموظفين';

  @override
  String get noStaff => 'مفيش موظفين لسه';

  @override
  String get addStaff => 'ضيف موظف';

  @override
  String get firstName2 => 'الاسم الأول';

  @override
  String get staffPermissions => 'الصلاحيات';

  @override
  String get staffCourts => 'الملاعب (من غير اختيار = كلها)';

  @override
  String get staffAdded => 'الموظف اتضاف';

  @override
  String get staffRemoved => 'اتشال';

  @override
  String get removeStaff => 'شيل';

  @override
  String get activateStaff => 'فعّال';

  @override
  String get resetPassword => 'تغيير كلمة المرور';

  @override
  String get passwordReset => 'كلمة المرور اتغيّرت';

  @override
  String get activityLog => 'النشاط';

  @override
  String get noActivity => 'مفيش نشاط لسه';

  @override
  String get permManageBookings => 'إدارة الحجوزات';

  @override
  String get permManualBookings => 'حجوزات يدوية';

  @override
  String get permViewReports => 'عرض التقارير';

  @override
  String get permCheckIn => 'تسجيل الحضور';

  @override
  String get permManageSlots => 'قفل المواعيد';

  @override
  String get permRatePlayers => 'تقييم اللاعيبة';

  @override
  String get permTournamentResults => 'نتايج البطولات';

  @override
  String get permEditCourts => 'تعديل الملاعب';

  @override
  String get permManageTournaments => 'إدارة البطولات';

  @override
  String get createTournament => 'بطولة جديدة';

  @override
  String get tournamentName => 'اسم البطولة';

  @override
  String get enterTournamentName => 'اكتب اسم البطولة';

  @override
  String get rulesField => 'القواعد (اختياري)';

  @override
  String get prizesField => 'الجوايز (اختياري)';

  @override
  String get individualSwitch => 'فردي (لاعب واحد في كل مشاركة)';

  @override
  String get playersPerTeamLabel => 'لاعيبة الفريق';

  @override
  String get substitutesLabel => 'احتياطي الفريق';

  @override
  String get maxTeamsLabel => 'أقصى عدد فرق';

  @override
  String get groupsCountLabel => 'عدد المجموعات';

  @override
  String get qualifiersLabel => 'المتأهلين من كل مجموعة';

  @override
  String get registrationCloseLabel => 'التسجيل بيقفل';

  @override
  String get startDateLabel => 'تاريخ البداية';

  @override
  String get endDateLabel => 'تاريخ النهاية';

  @override
  String get dailyStartLabel => 'بداية اليوم';

  @override
  String get dailyEndLabel => 'نهاية اليوم';

  @override
  String get matchMinutesLabel => 'مدة الماتش';

  @override
  String get pickCourts => 'الملاعب المستخدمة';

  @override
  String get tournamentCreated => 'البطولة اتعملت';

  @override
  String get publishTournament => 'انشر';

  @override
  String get closeRegistration => 'اقفل التسجيل';

  @override
  String get drawTournament => 'اسحب وجدول';

  @override
  String get cancelTournament => 'الغي البطولة';

  @override
  String get cancelTournamentTitle => 'تلغي البطولة دي؟';

  @override
  String get cancelReasonRequired => 'السبب (مطلوب)';

  @override
  String get tournamentActionDone => 'تمام';

  @override
  String get approveTeam => 'قبول';

  @override
  String get rejectTeam => 'رفض';

  @override
  String get rejectTeamTitle => 'رفض الفريق';

  @override
  String get noManagedTournaments => 'لسه معملتش بطولة';

  @override
  String get enterResult => 'سجّل النتيجة';

  @override
  String get homeScore => 'نتيجة الأول';

  @override
  String get awayScore => 'نتيجة التاني';

  @override
  String get winnerOnDraw => 'الفايز (مطلوب لو تعادل)';

  @override
  String get resultSaved => 'النتيجة اتسجلت';

  @override
  String get pickPoster => 'تغيير البوستر';

  @override
  String get teamsPending => 'مستنيك';

  @override
  String get mustPickCourt => 'اختار ملعب واحد على الأقل';

  @override
  String get recurringBooking => 'احجز كل أسبوع';

  @override
  String get recurringTitle => 'حجز أسبوعي';

  @override
  String get weeksCount => 'عدد الأسابيع';

  @override
  String get firstDay => 'أول يوم';

  @override
  String get skipUnavailable => 'تخطّى الأسابيع المحجوزة';

  @override
  String get previewWeeks => 'شوف الأسابيع';

  @override
  String get weekAvailable => 'متاح';

  @override
  String get weekTaken => 'محجوز';

  @override
  String availableWeeksTotal(int count, String price) {
    return '$count أسبوع متاح · الإجمالي $price جنيه';
  }

  @override
  String get confirmRecurring => 'احجز الأسابيع المتاحة';

  @override
  String get recurringCreated => 'الحجز الأسبوعي اتعمل';

  @override
  String get myRecurring => 'الحجوزات الأسبوعية';

  @override
  String get noRecurring => 'مفيش حجوزات أسبوعية';

  @override
  String everyWeekDay(String day) {
    return 'كل $day';
  }

  @override
  String weeksOf(int count, String day) {
    return '$count أسبوع من $day';
  }

  @override
  String get cancelRecurring => 'الغي الكل';

  @override
  String get recurringCancelled => 'الحجز الأسبوعي اتلغى';

  @override
  String get tabWeekly => 'أسبوعي';

  @override
  String get repeatWeekly => 'كرّر كل أسبوع';

  @override
  String get recurringStatusPending => 'مستني النادي';

  @override
  String get recurringStatusConfirmed => 'متأكد';

  @override
  String get recurringStatusRejected => 'مرفوض';

  @override
  String get recurringStatusCancelled => 'ملغي';

  @override
  String get recurringStatusExpired => 'منتهي';

  @override
  String get clubPhotos => 'صور النادي';

  @override
  String get courtPhotos => 'صور الملعب';

  @override
  String get addPhotos2 => 'ضيف صور';

  @override
  String get deletePhoto => 'امسح الصورة';

  @override
  String get setCover => 'خليها الغلاف';

  @override
  String get photoAdded => 'الصور اتضافت';

  @override
  String get photoDeleted => 'الصورة اتمسحت';

  @override
  String get coverSet => 'الغلاف اتغيّر';

  @override
  String get noPhotos => 'مفيش صور لسه';

  @override
  String get courtPhotosMenu => 'الصور';

  @override
  String get reports => 'التقارير';

  @override
  String get reportPeriod7 => '7 أيام';

  @override
  String get reportPeriod30 => '30 يوم';

  @override
  String get reportPeriod90 => '90 يوم';

  @override
  String get revenue => 'الإيراد';

  @override
  String get bookingsTotal => 'الحجوزات';

  @override
  String get noShowRate => 'نسبة عدم الحضور';

  @override
  String get occupancy => 'إشغال الملاعب';

  @override
  String get peakHours => 'أوقات الذروة';

  @override
  String get bySource => 'مصدر الحجوزات';

  @override
  String get topCustomers => 'أكتر العملاء';

  @override
  String get ratingsSummary => 'التقييمات';

  @override
  String get sourceApp => 'التطبيق';

  @override
  String get sourceManual => 'يدوي';

  @override
  String hoursBooked(String booked, String available) {
    return '$booked من $available ساعة';
  }

  @override
  String get rescheduleMatch => 'تغيير الميعاد';

  @override
  String get rescheduled => 'الماتش اتأجل';

  @override
  String get pickCourt => 'الملعب';

  @override
  String get becomeOwner => 'صاحب نادي؟ انضم لسبورتيفا';

  @override
  String get membershipTitle => 'طلب صاحب نادي';

  @override
  String get membershipIntro => 'عرّفنا بنادييك. فريق سبورتيفا بيراجع الطلب وبيجهّز ناديك.';

  @override
  String get applicantName => 'اسمك بالكامل';

  @override
  String get enterFullName => 'اكتب اسمك بالكامل';

  @override
  String get clubNameField => 'اسم النادي';

  @override
  String get enterClubName => 'اكتب اسم النادي';

  @override
  String get addressHint => 'الشارع، المنطقة';

  @override
  String get locationUrl => 'لينك الخريطة (اختياري)';

  @override
  String get attachFiles => 'صور وفيديوهات للنادي';

  @override
  String attachHint(int images, int videos) {
    return 'لحد $images صور و$videos فيديو';
  }

  @override
  String get addVideoShort => 'ضيف فيديو';

  @override
  String tooManyVideos(int count) {
    return 'أقصى عدد فيديوهات $count';
  }

  @override
  String get submitRequest => 'ابعت الطلب';

  @override
  String get requestSentMembership => 'طلبك اتبعت';

  @override
  String get membershipPending => 'تحت المراجعة';

  @override
  String get membershipApproved => 'اتقبل';

  @override
  String get membershipRejected => 'اترفض';

  @override
  String get membershipPendingBody => 'هنبلغك أول ما الفريق يراجعه.';

  @override
  String get membershipApprovedBody => 'حسابك بقى حساب صاحب نادي. الفريق هيربط ناديك قريب.';

  @override
  String get membershipRejectedBody => 'تقدر تبعت طلب جديد.';

  @override
  String get rejectionReasonLabel => 'السبب';

  @override
  String get newRequest => 'ابعت طلب جديد';

  @override
  String get mediaProcessing => 'بيتجهّز';

  @override
  String get mediaFailed => 'فشل';

  @override
  String get addMoreFiles => 'ضيف ملفات كمان';

  @override
  String get removeFile => 'شيل';

  @override
  String get yourRequest => 'طلبك';

  @override
  String get preferredSports => 'رياضاتي المفضلة';

  @override
  String get preferredSportsHint => 'اختار الرياضات اللي بتلعبها';

  @override
  String get preferredSportsSaved => 'اتحفظ';

  @override
  String get matchOnCourt => 'ماتش على ملعب نادي';

  @override
  String get matchOnOutside => 'ماتش في مكان تاني';

  @override
  String get pickClubCourt => 'اختار الملعب والميعاد من صفحة النادي، وبعدها افتح الماتش من حجزك.';

  @override
  String get openAsMatch => 'افتحه كماتش';

  @override
  String get openAsMatchHint => 'اللاعيبة يقدروا يطلبوا الانضمام أول ما النادي يأكد';

  @override
  String get openMatchNow => 'احجز وافتح الماتش';

  @override
  String get pickCourtTitle => 'اختار ملعب';

  @override
  String get pickCourtButton => 'اختار ملعب';

  @override
  String get chooseCourtForMatch => 'الماتش على ملعب نادي: اختار الملعب واليوم والميعاد.';

  @override
  String get matchStartedOnCourt => 'حجز الملعب اتعمل، والماتش بيتفتح لما النادي يأكد';

  @override
  String get paymentSucceeded => 'الدفع تم. شكرًا!';

  @override
  String get paymentFailed => 'الدفع ماتمش. تقدر تجرّب تاني.';

  @override
  String get paymentExpired => 'صفحة الدفع انتهت. ابدأ من تاني.';

  @override
  String get paymentChecking => 'بنتأكد من الدفع...';

  @override
  String get noPaymentMethods => 'الدفع مش متاح دلوقتي';

  @override
  String get paymentRefunded => 'فلوسك اترجعت';

  @override
  String get notificationChannelName => 'تنبيهات سبورتيفا';

  @override
  String get notificationChannelDescription => 'الحجوزات والماتشات والبطولات والرسايل وغيرها';

  @override
  String distanceAway(String km) {
    return 'يبعد $km كم';
  }

  @override
  String morePlayers(int count) {
    return '+$count';
  }

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'حسب الهاتف';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchFilters => 'الفلاتر';

  @override
  String get filterSport => 'الرياضة';

  @override
  String get filterGovernorate => 'المحافظة';

  @override
  String get filterAnyGovernorate => 'أي مكان';

  @override
  String get filterCityHint => 'المدينة مثل طنطا';

  @override
  String get filterPrice => 'السعر في الساعة';

  @override
  String get filterPriceAny => 'أي سعر';

  @override
  String filterPriceFrom(String min) {
    return 'من $min ج.م';
  }

  @override
  String filterPriceUpTo(String max) {
    return 'حتى $max ج.م';
  }

  @override
  String filterPriceBetween(String min, String max) {
    return '$min - $max ج.م';
  }

  @override
  String get filterRating => 'التقييم';

  @override
  String get filterRatingAny => 'الكل';

  @override
  String filterRatingFrom(String rating) {
    return '$rating+ نجوم';
  }

  @override
  String get filterDistance => 'المسافة منك';

  @override
  String get filterDistanceAny => 'أي مسافة';

  @override
  String get filterDistanceNeedsLocation => 'فعّل الموقع عشان تفلتر بالمسافة';

  @override
  String get filterSort => 'ترتيب حسب';

  @override
  String get sortNearest => 'الأقرب';

  @override
  String get sortPriceLow => 'السعر: الأقل أولًا';

  @override
  String get sortPriceHigh => 'السعر: الأعلى أولًا';

  @override
  String get sortRating => 'الأعلى تقييمًا';

  @override
  String get filtersApply => 'عرض النتائج';

  @override
  String get filtersReset => 'إعادة ضبط';

  @override
  String get searchNoResults => 'مفيش نتائج مطابقة';

  @override
  String get searchNoResultsHint => 'جرّب تشيل فلتر أو تبحث عن حاجة تانية.';

  @override
  String get searchClearFilters => 'مسح الفلاتر';

  @override
  String kmShort(String km) {
    return '$km كم';
  }

  @override
  String fromPrice(String price) {
    return 'من $price ج.م / ساعة';
  }

  @override
  String get nearbyBadge => 'قريب منك';

  @override
  String get playerPosition => 'المركز';

  @override
  String get positionGoalkeeper => 'حارس مرمى';

  @override
  String get positionDefender => 'مدافع';

  @override
  String get positionMidfielder => 'لاعب وسط';

  @override
  String get positionForward => 'مهاجم';

  @override
  String get preferredFoot => 'القدم المفضلة';

  @override
  String get footRight => 'اليمين';

  @override
  String get footLeft => 'الشمال';

  @override
  String get footBoth => 'الاتنين';

  @override
  String get traitsHint => 'اللاعبين التانيين بيشوفوا ده في بروفايلك.';

  @override
  String get searchClubsTab => 'الأندية';

  @override
  String get forYou => 'لك';

  @override
  String get savePost => 'حفظ';

  @override
  String get sharePost => 'مشاركة';

  @override
  String get savedPosts => 'المحفوظات';

  @override
  String get noSavedPosts => 'لسه مفيش حاجة محفوظة';

  @override
  String get postSaved => 'اتضاف للمفضلة';

  @override
  String get postUnsaved => 'اتشال من المفضلة';

  @override
  String get showMore => 'المزيد';

  @override
  String get showLess => 'أقل';

  @override
  String get followAuthor => 'متابعة';

  @override
  String get replyToLabel => 'رد';

  @override
  String get myPostsNew => 'منشور جديد';

  @override
  String get shareFailed => 'مقدرناش نشارك';

  @override
  String get voiceRecording => 'بيسجّل';

  @override
  String get voiceCancel => 'إلغاء';

  @override
  String get voiceSend => 'ابعت الرسالة الصوتية';

  @override
  String get voiceMaxReached => 'أقصى مدة 30 ثانية';

  @override
  String get micPermission => 'اسمح بالميكروفون عشان تسجّل رسالة صوتية';

  @override
  String get voiceMessage => 'رسالة صوتية';

  @override
  String get recordVoice => 'سجّل رسالة صوتية';

  @override
  String get repost => 'ريبوست';

  @override
  String get reposted => 'اتعمل ريبوست';

  @override
  String repostedBy(String name) {
    return '$name عمل ريبوست';
  }

  @override
  String get youReposted => 'انت عملت ريبوست';

  @override
  String get repostDone => 'اتشاركت مع متابعينك';

  @override
  String get repostUndone => 'اتشال الريبوست';

  @override
  String get suggestedPeople => 'ناس ممكن تعرفهم';

  @override
  String followedByMutual(int count) {
    return '$count من اللي بتتابعهم متابعينه';
  }

  @override
  String get sameGovernorateHint => 'من محافظتك';

  @override
  String popularHint(int count) {
    return '$count متابع';
  }

  @override
  String get searchAll => 'الكل';

  @override
  String get coverChanged => 'اتغيّر الغلاف';

  @override
  String get searchTournaments => 'ابحث عن بطولة';

  @override
  String get searchMatches => 'ابحث بالمكان أو النادي أو المنظّم';

  @override
  String get shareMatch => 'مشاركة';

  @override
  String get shareToFriend => 'ابعت لصاحبك';

  @override
  String get shareOutside => 'مشاركة برا التطبيق';

  @override
  String matchShareText(String title, String when, String id) {
    return 'ماتش ودي: $title\n$when\nافتحه في سبورتيفا: /match/$id';
  }

  @override
  String get sentToFriend => 'اتبعتت';

  @override
  String get phoneNeededTitle => 'رقم موبايلك';

  @override
  String get phoneNeededBody => 'النادي محتاج رقمك عشان يتواصل معاك بخصوص الحجز.';

  @override
  String get pickOnMap => 'اختار من الخريطة';

  @override
  String get changeOnMap => 'غيّر من الخريطة';

  @override
  String get mapSearchHint => 'ابحث عن مكان';

  @override
  String get useThisLocation => 'استخدم المكان ده';

  @override
  String get locationPicked => 'اتحدد المكان';

  @override
  String get mapSearchFailed => 'البحث مش متاح دلوقتي';

  @override
  String get noPlaceFound => 'ملقيناش مكان بالاسم ده';

  @override
  String get dragMapHint => 'حرّك الخريطة لحد ما الدبوس ييجي على المكان';

  @override
  String get posterOptional => 'صورة البطولة (اختياري)';

  @override
  String get pickPosterNow => 'اختار صورة';
}

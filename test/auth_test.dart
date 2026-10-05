import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportiva_app/core/localization/locale_controller.dart';
import 'package:sportiva_app/core/network/api_exception.dart';
import 'package:sportiva_app/core/theme/app_theme.dart';
import 'package:sportiva_app/core/validation/validators.dart';
import 'package:sportiva_app/core/widgets/otp_field.dart';
import 'package:sportiva_app/features/auth/presentation/auth_route_args.dart';
import 'package:sportiva_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:sportiva_app/features/auth/presentation/login_screen.dart';
import 'package:sportiva_app/features/auth/presentation/otp_screen.dart';
import 'package:sportiva_app/features/auth/presentation/sign_up_screen.dart';
import 'package:sportiva_app/l10n/app_localizations.dart';

Future<void> pumpScreen(WidgetTester tester, Widget screen, {String language = 'en'}) async {
  SharedPreferences.setMockInitialValues({'locale': language});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  );
  await tester.pump();
}

DioException dioError(int status, Object data) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: data,
  ),
);

void main() {
  group('ApiException', () {
    test('reads a business error (code + message)', () {
      final e = ApiException.fromDio(
        dioError(401, {
          'errors': ['User.EmailNotConfirmed', 'Email not confirmed'],
        }),
      );
      expect(e.kind, ApiErrorKind.server);
      expect(e.hasCode('User.EmailNotConfirmed'), isTrue);
      expect(e.message, 'Email not confirmed');
    });

    test('reads a validation error', () {
      final e = ApiException.fromDio(
        dioError(400, {
          'errors': {
            'Code': ['The code must be 6 digits'],
          },
        }),
      );
      expect(e.message, 'The code must be 6 digits');
    });

    test('no response means the network is down', () {
      final e = ApiException.fromDio(DioException(requestOptions: RequestOptions(path: '/x')));
      expect(e.kind, ApiErrorKind.network);
    });
  });

  group('Validators', () {
    late Validators v;
    setUp(() => v = Validators(lookupAppLocalizations(const Locale('en'))));

    test('email', () {
      expect(v.email('a@b.com'), isNull);
      expect(v.email('nope'), isNotNull);
      expect(v.email(''), isNotNull);
    });

    test('password matches the API rule', () {
      expect(v.password('Sportiva@Admin2026'), isNull);
      expect(v.password('Test#2026ab'), isNull);
      expect(v.password('weakpass'), isNotNull);
      expect(v.password('NoSymbol2026'), isNotNull);
      expect(v.password('Sh0rt!'), isNotNull);
    });

    test('names need 3 characters', () {
      expect(v.name('Al'), isNotNull);
      expect(v.name('Ali'), isNull);
    });
  });

  testWidgets('login validates and has Google only', (tester) async {
    await pumpScreen(tester, const LoginScreen());

    expect(find.text('Login'), findsWidgets);
    expect(find.text('or login with'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsNothing);
    expect(find.text('This field is required'), findsNWidgets(2));
  });

  testWidgets('login renders right to left in Arabic', (tester) async {
    await pumpScreen(tester, const LoginScreen(), language: 'ar');

    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(Directionality.of(tester.element(find.byType(LoginScreen))), TextDirection.rtl);
  });

  testWidgets('sign up checks the repeated password', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 1400);
    addTearDown(tester.view.reset);
    await pumpScreen(tester, const SignUpScreen());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(3), 'Test#2026ab');
    await tester.enterText(fields.at(4), 'different');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text("Passwords don't match"), findsOneWidget);
  });

  testWidgets('forgot password button is disabled until an email is typed', (tester) async {
    await pumpScreen(tester, const ForgotPasswordScreen());

    ElevatedButton button() => tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextFormField), 'a@b.com');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('otp screen fills six boxes and enables Verify', (tester) async {
    await pumpScreen(
      tester,
      const OtpScreen(
        args: OtpArgs(email: 'a@b.com', purpose: OtpPurpose.resetPassword),
      ),
    );

    ElevatedButton button() => tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button().onPressed, isNull);
    expect(find.text('Resend in 60s'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(button().onPressed, isNotNull);
    for (final digit in '123456'.split('')) {
      expect(find.text(digit), findsOneWidget);
    }
    expect(find.byType(OtpField), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}

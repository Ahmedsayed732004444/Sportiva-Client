# Sportiva Client

تطبيق Flutter لمنصة Sportiva (حجز الملاعب، الماتشات، السوشيال، البطولات، وإدارة النادي). عربي/إنجليزي (RTL/LTR) بخط Almarai.
Flutter client for the Sportiva API: courts booking, friendly matches, social, tournaments and club management. Arabic + English.

API: `https://sportivaa.runasp.net` (Swagger: `/swagger`)

## المتطلبات / Requirements
- Flutter **3.41+** (Dart 3.11+) — `flutter --version`
- Android Studio (Android SDK + emulator) أو Xcode للـ iOS
- `flutter doctor` يطلع نضيف

## التنزيل والتشغيل / Setup
```bash
git clone https://github.com/Ahmedsayed732004444/Sportiva-Client.git
cd Sportiva-Client
flutter pub get
flutter gen-l10n            # بس لو عدّلت ملفات lib/l10n/*.arb
flutter run                 # على الإيميوليتور أو موبايل متوصل
```
شغّل إيميوليتور الأول (`flutter emulators --launch <id>`) أو وصّل موبايل بـ USB، وبعدين `flutter run -d <device-id>` (`flutter devices` بيعرض الأجهزة).
بعد إضافة أي package جديد اعمل **stop** وشغّل بالأمر الكامل (مش hot restart).

## الإعدادات / Configuration
بتتعدّل بـ `--dart-define` من غير ما تلمس الكود:

| المتغير | الافتراضي | الاستخدام |
|---|---|---|
| `API_BASE_URL` | `https://sportivaa.runasp.net` | لو عايز تشتغل على API محلي: `http://10.0.2.2:5036` (الإيميوليتور) |
| `GOOGLE_SERVER_CLIENT_ID` | Web client ID بتاع المشروع | لازم يساوي `Authentication:Google:ClientId` في الـ API |

مثال: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5036`

## تسجيل الدخول بجوجل / Google sign-in
- التسجيل بالإيميل وكود التأكيد شغّال على طول.
- تسجيل جوجل على Android محتاج إن **SHA-1** بتاع الـ keystore اللي بتبني بيه يكون مسجّل في Android OAuth client في Google Cloud (نفس package: `com.sportiva.sportiva_app`).
  - الـ SHA-1 بتاع الـ debug: `cd android && ./gradlew signingReport`
- الموقع الجغرافي: اضبط موقع الإيميوليتور من Extended controls → Location عشان "أقرب الملاعب" تظهر.

## الاختبارات / Tests
```bash
flutter analyze
flutter test
```

## بناء APK / Build
```bash
flutter build apk --release        # build/app/outputs/flutter-apk/app-release.apk
```
(بيحتاج RAM كفاية؛ اقفل البرامج التقيلة لو الـ build اتقتل.)

## الهيكل / Structure
```
lib/
  core/       theme, network (Dio + token refresh), realtime (SignalR), router, localization, shared widgets
  features/   auth, home, catalog (clubs/courts), booking, matches, social, chat, tournaments,
              reviews, settings, profile, notifications, owner (club management)
  l10n/       app_en.arb, app_ar.arb
test/         unit + widget tests
```
- State: Riverpod · Navigation: go_router · Network: Dio · Live updates: SignalR (`/hubs/realtime`)
- لإضافة نص جديد: ضيفه في الملفين `app_en.arb` و`app_ar.arb` وبعدين `flutter gen-l10n`.

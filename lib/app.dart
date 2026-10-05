import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/locale_controller.dart';
import 'core/realtime/realtime_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/snack.dart';
import 'features/notifications/application/system_notifications.dart';
import 'features/payments/application/payment_providers.dart';
import 'features/settings/application/account_providers.dart';
import 'l10n/app_localizations.dart';

class SportivaApp extends ConsumerStatefulWidget {
  const SportivaApp({super.key});

  @override
  ConsumerState<SportivaApp> createState() => _SportivaAppState();
}

class _SportivaAppState extends ConsumerState<SportivaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The phone switched between light and dark: matters only while "follow the phone" is picked.
  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() {});
  }

  // Colours are read from [AppColors] when a widget builds, so when the palette flips every widget has to build again.
  void _rebuildEverything() {
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the live connection open while signed in.
    ref.watch(realtimeLifecycleProvider);
    ref.watch(languageSyncProvider);
    ref.watch(paymentFeedbackProvider);
    ref.watch(systemNotificationsProvider);

    final mode = ref.watch(themeModeProvider);
    final dark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    if (dark != AppColors.dark) {
      AppColors.dark = dark;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _rebuildEverything();
      });
    }

    return MaterialApp.router(
      scaffoldMessengerKey: rootMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.build(),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

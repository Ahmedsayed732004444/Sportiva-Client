import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('Override in main()'));

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  static const _key = 'locale';
  static const supported = [Locale('en'), Locale('ar')];

  @override
  Locale build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    final code = saved ?? ui.PlatformDispatcher.instance.locale.languageCode;
    return supported.firstWhere((l) => l.languageCode == code, orElse: () => const Locale('en'));
  }

  Future<void> toggle() async {
    state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await ref.read(sharedPreferencesProvider).setString(_key, state.languageCode);
  }
}

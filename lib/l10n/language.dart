import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/shared_preferences_provider.dart';

final languageProvider = StateNotifierProvider<LanguageController, Locale>(
  (ref) => LanguageController(ref),
);

class LanguageController extends StateNotifier<Locale> {
  LanguageController(this._ref) : super(const Locale('en')) {
    _load();
  }

  final Ref _ref;
  bool _changed = false;
  static const _key = 'language';

  Future<void> _load() async {
    final preferences = await _ref.read(sharedPreferencesProvider.future);
    final language = preferences.getString(_key);
    if (mounted && !_changed && (language == 'ru' || language == 'en')) {
      state = Locale(language!);
    }
  }

  Future<void> setLanguage(String language) async {
    if (language != 'en' && language != 'ru') return;
    _changed = true;
    state = Locale(language);
    final preferences = await _ref.read(sharedPreferencesProvider.future);
    await preferences.setString(_key, language);
  }
}

import 'package:package_flutter/domain/core/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_dark_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class MapDarkMode extends _$MapDarkMode {
  @override
  bool build() {
    final sharedPrefs = ref.watch(sharedPreferencesProvider).value;
    return sharedPrefs?.getBool('isDarkModeEnabled') ?? true;
  }

  Future<void> setDarkMode(bool isDarkModeEnabled) async {
    state = isDarkModeEnabled;
    final sharedPrefs = await ref.read(sharedPreferencesProvider.future);
    await sharedPrefs.setBool('isDarkModeEnabled', isDarkModeEnabled);
  }
}

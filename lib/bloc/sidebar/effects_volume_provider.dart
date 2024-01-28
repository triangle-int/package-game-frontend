import 'package:package_flutter/domain/core/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'effects_volume_provider.g.dart';

@Riverpod(keepAlive: true)
class EffectsVolume extends _$EffectsVolume {
  @override
  double build() {
    final sharedPrefs = ref.watch(sharedPreferencesProvider).value;
    return sharedPrefs?.getDouble('effectsVolume') ?? 1;
  }

  Future<void> setVolume(double volume) async {
    state = volume;
    final sharedPrefs = await ref.read(sharedPreferencesProvider.future);
    await sharedPrefs.setDouble('effectsVolume', volume);
  }
}

import 'package:package_flutter/domain/core/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_volume_provider.g.dart';

@Riverpod(keepAlive: true)
class MusicVolume extends _$MusicVolume {
  @override
  double build() {
    final sharedPrefs = ref.watch(sharedPreferencesProvider).value;
    return sharedPrefs?.getDouble('musicVolume') ?? 0.75;
  }

  Future<void> setVolume(double volume) async {
    state = volume;
    final sharedPrefs = await ref.read(sharedPreferencesProvider.future);
    await sharedPrefs.setDouble('musicVolume', volume);
  }
}

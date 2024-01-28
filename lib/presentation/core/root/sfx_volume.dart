import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sfx_volume.g.dart';

@riverpod
class SfxVolume extends _$SfxVolume {
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

class SfxVolumeWidget extends ConsumerWidget {
  const SfxVolumeWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sfxVolumeProvider);
    return child;
  }
}

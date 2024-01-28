import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/domain/booster/booster_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booster_activate_provider.g.dart';

@riverpod
class BoosterActivate extends _$BoosterActivate {
  @override
  Future<void> build(String boosterName) async {}

  Future<void> activate() async {
    state = const AsyncValue.loading();

    final boosterRepository = ref.read(boosterRepositoryProvider);

    state = await AsyncValue.guard(() async {
      boosterRepository.useBooster(boosterName);
      ref.invalidate(activatedBoostersProvider);
    });
  }
}

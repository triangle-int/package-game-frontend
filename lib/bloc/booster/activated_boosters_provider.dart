import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/booster/booster.dart';
import 'package:package_flutter/domain/booster/booster_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activated_boosters_provider.g.dart';

@riverpod
class ActivatedBoosters extends _$ActivatedBoosters {
  @override
  Future<List<Booster>> build() {
    Logger().d('Getting activated boosters...');
    return ref.watch(boosterRepositoryProvider).getActiveBoosters();
  }

  int getBoostedValue({
    required String boosterType,
    required int value,
    required double factor,
  }) {
    final booster =
        state.valueOrNull?.where((b) => b.type == boosterType).firstOrNull;

    return booster != null && booster.endsAt.isAfter(DateTime.now())
        ? (value * factor).floor()
        : value;
  }

  int getBoostedCost(int cost) {
    final config = ref.read(configProvider).value!;
    return getBoostedValue(
      boosterType: config.boosterTypes.priceDecrease,
      value: cost,
      factor: config.boosterPriceDecreaseFactor,
    );
  }

  int getBoostedIncome(int income) {
    final config = ref.read(configProvider).value!;
    return getBoostedValue(
      boosterType: config.boosterTypes.businessIncome,
      value: income,
      factor: config.boosterIncomeFactor,
    );
  }

  int getBoostedTruckDuration(int duration) {
    final config = ref.read(configProvider).value!;
    return getBoostedValue(
      boosterType: config.boosterTypes.deliverySpeed,
      value: duration,
      factor: config.boosterTruckFactor,
    );
  }

  int getBoostedFactoryProduction(int production) {
    final config = ref.read(configProvider).value!;
    return getBoostedValue(
      boosterType: config.boosterTypes.factoryProduction,
      value: production,
      factor: config.boosterFactoryFactor,
    );
  }
}

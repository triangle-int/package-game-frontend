import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/booster/booster_type.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/config/store_item.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
abstract class Config with _$Config {
  const Config._();

  const factory Config({
    required List<String> avatars,
    required int startMoney,
    required int interactionRadiusKm,
    required int buildingsCellLevel,
    required int storageCost,
    required int factoryCost,
    required List<int> satelliteCosts,
    required List<int> businessCosts,
    required Map<String, String> businessEmoji,
    required List<int> satelliteRadius,
    required List<Item> items,
    required List<int> factoryUpgradeCosts,
    required List<int> factoryResourcesPerMinute,
    required List<double> trucksCost,
    required List<int> businessMoneyPerMinute,
    required double businessTaxMultiplier,
    required List<int> expreienceForLevel,
    required int factoryResourcesLimit,
    required Map<String, List<StoreItem>> storeItems,
    required double boosterPriceDecreaseFactor,
    required double boosterIncomeFactor,
    required double boosterTruckFactor,
    required double boosterFactoryFactor,
    required int boosterDuration,
    required BoosterTypes boosterTypes,
  }) = _Config;

  Item getItemByName(String name) {
    return items.firstWhere(
      (i) => i.name == name,
      orElse: () => Item.unknown(name: name),
    );
  }

  String getBusinessEmoji(int level) {
    return businessEmoji.entries
        .lastWhere((e) => int.parse(e.key) <= level)
        .value;
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
}

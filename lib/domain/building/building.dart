import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building_owner.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';

part 'building.freezed.dart';
part 'building.g.dart';

@Freezed(unionKey: 'discriminator')
sealed class Building with _$Building {
  const Building._();

  const factory Building.business({
    required int id,
    required String geohex,
    required String? geohash,
    required String? resourceToUpgrade1,
    required int level,
    required int ownerId,
    required DateTime updatedAt,
    BuildingOwner? owner,
  }) = BusinessBuilding;

  const factory Building.storage({
    required int id,
    required int level,
    required String geohex,
    required String? geohash,
    required int ownerId,
    BuildingOwner? owner,
    List<InventoryItem>? inventory,
  }) = StorageBuilding;

  const factory Building.factory({
    required int id,
    required String geohex,
    required String? geohash,
    required String? currentResource,
    required String? resourceToUpgrade1,
    required String? resourceToUpgrade2,
    required String? resourceToUpgrade3,
    required int level,
    required int ownerId,
    required bool enabled,
    BuildingOwner? owner,
    List<InventoryItem>? inventory,
  }) = FactoryBuilding;

  const factory Building.market({
    required int id,
    required String geohex,
    required String? geohash,
    required int level,
    required double? commission,
    List<InventoryItem>? inventory,
  }) = MarketBuilding;

  const factory Building.satellite({
    required int id,
    required String geohex,
    required String? geohash,
    required int level,
    required int? ownerId,
    BuildingOwner? owner,
    required List<SatelliteBuilding>? children,
  }) = SatelliteBuilding;

  String getEmoji(Config config) {
    return switch (this) {
      BusinessBuilding() => config.getBusinessEmoji(level),
      StorageBuilding() => '⛺️',
      FactoryBuilding() => '🏭',
      MarketBuilding() => '🏬',
      SatelliteBuilding() => '🛰',
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);
}

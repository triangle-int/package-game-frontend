import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';

part 'delivery_buildings.freezed.dart';
part 'delivery_buildings.g.dart';

@freezed
abstract class DeliveryBuildings with _$DeliveryBuildings {
  const factory DeliveryBuildings({
    required List<Building> starts,
    required List<Building> destinations,
  }) = _DeliveryBuildings;

  factory DeliveryBuildings.fromJson(Map<String, dynamic> json) =>
      _$DeliveryBuildingsFromJson(json);
}

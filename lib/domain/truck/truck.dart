import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';

part 'truck.freezed.dart';
part 'truck.g.dart';

@freezed
abstract class Truck with _$Truck {
  const factory Truck({
    required int id,
    required DateTime startTime,
    required DateTime endTime,
    required String path,
    required int truckType,
    required int destinationId,
    required Building? destinationBuilding,
    required int startId,
    required Building? startBuilding,
    required String resource,
    required BigInt resourceCount,
    required int? scheduleId,
    required int ownerId,
  }) = _Truck;

  factory Truck.fromJson(Map<String, dynamic> json) => _$TruckFromJson(json);
}

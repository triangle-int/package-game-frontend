import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/truck/truck.dart';

part 'truck_schedule.freezed.dart';
part 'truck_schedule.g.dart';

@freezed
class TruckSchedule with _$TruckSchedule {
  const factory TruckSchedule({
    required int id,
    required DateTime nextTime,
    required int interval,
    required int truckType,
    required String resource,
    required int resourceCount,
    required Building start,
    required int startId,
    required Building destination,
    required int destinationId,
    required String lastPath,
    required List<Truck> trucks,
  }) = _TruckSchedule;

  factory TruckSchedule.fromJson(Map<String, dynamic> json) =>
      _$TruckScheduleFromJson(json);
}

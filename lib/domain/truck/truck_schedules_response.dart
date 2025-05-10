import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_schedule.dart';

part 'truck_schedules_response.freezed.dart';
part 'truck_schedules_response.g.dart';

@freezed
abstract class TruckSchedulesResponse with _$TruckSchedulesResponse {
  const factory TruckSchedulesResponse({
    required List<TruckSchedule> schedules,
    required List<Truck> trucks,
  }) = _TruckSchedulesResponse;

  factory TruckSchedulesResponse.fromJson(Map<String, dynamic> json) =>
      _$TruckSchedulesResponseFromJson(json);
}

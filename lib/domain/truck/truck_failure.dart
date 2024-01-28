import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'truck_failure.freezed.dart';

@freezed
class TruckFailure with _$TruckFailure {
  const factory TruckFailure.resourceNotSelected() = _ResourceNotSelected;
  const factory TruckFailure.pointANotSelected() = _PointANotSelected;
  const factory TruckFailure.pointBNotSelected() = _PointBNotSelected;
  const factory TruckFailure.amountIsZero() = _AmountIsZero;
  const factory TruckFailure.pathNotCalculated() = _PathNotCalculated;
  const factory TruckFailure.serverFailure(ServerFailure f) = _ServerFailure;
}

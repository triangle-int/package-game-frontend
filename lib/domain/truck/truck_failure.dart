import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'truck_failure.freezed.dart';

@freezed
sealed class TruckFailure with _$TruckFailure {
  const factory TruckFailure.resourceNotSelected() =
      TruckFailureResourceNotSelected;
  const factory TruckFailure.pointANotSelected() =
      TruckFailurePointANotSelected;
  const factory TruckFailure.pointBNotSelected() =
      TruckFailurePointBNotSelected;
  const factory TruckFailure.amountIsZero() = TruckFailureAmountIsZero;
  const factory TruckFailure.pathNotCalculated() =
      TruckFailurePathNotCalculated;
  const factory TruckFailure.serverFailure(ServerFailure f) =
      TruckFailureServerFailure;
}

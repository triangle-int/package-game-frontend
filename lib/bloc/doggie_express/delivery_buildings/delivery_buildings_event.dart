part of 'delivery_buildings_bloc.dart';

@freezed
sealed class DeliveryBuildingsEvent with _$DeliveryBuildingsEvent {
  const factory DeliveryBuildingsEvent.buildingsRequested() =
      DeliveryBuildingsEventBuildingsRequested;
}

part of 'delivery_buildings_bloc.dart';

@freezed
class DeliveryBuildingsEvent with _$DeliveryBuildingsEvent {
  const factory DeliveryBuildingsEvent.buildingsRequested() =
      _BuildingsRequested;
}

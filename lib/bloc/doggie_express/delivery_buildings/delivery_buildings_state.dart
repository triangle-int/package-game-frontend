part of 'delivery_buildings_bloc.dart';

@freezed
class DeliveryBuildingsState with _$DeliveryBuildingsState {
  const factory DeliveryBuildingsState.initial() = _Initial;
  const factory DeliveryBuildingsState.loadInProgress() = _LoadInProgress;
  const factory DeliveryBuildingsState.loadFailure(ServerFailure f) =
      _LoadFailure;
  const factory DeliveryBuildingsState.loadSuccess(
    DeliveryBuildings buildings,
  ) = _LoadSuccess;
}

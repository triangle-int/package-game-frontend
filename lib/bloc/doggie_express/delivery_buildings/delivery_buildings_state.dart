part of 'delivery_buildings_bloc.dart';

@freezed
sealed class DeliveryBuildingsState with _$DeliveryBuildingsState {
  const factory DeliveryBuildingsState.initial() =
      DeliveryBuildingsStateInitial;
  const factory DeliveryBuildingsState.loadInProgress() =
      DeliveryBuildingsStateLoadInProgress;
  const factory DeliveryBuildingsState.loadFailure(ServerFailure f) =
      DeliveryBuildingsStateLoadFailure;
  const factory DeliveryBuildingsState.loadSuccess(
    DeliveryBuildings buildings,
  ) = DeliveryBuildingsStateLoadSuccess;
}

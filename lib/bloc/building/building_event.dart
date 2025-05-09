part of 'building_bloc.dart';

@freezed
sealed class BuildingEvent with _$BuildingEvent {
  const factory BuildingEvent.updatedBounds(
    LatLngBounds bounds,
  ) = UpdatedBounds;
  const factory BuildingEvent.buildingsReceived(
    Either<ServerFailure, List<Building>> buildingsOrFailure,
  ) = BuildingsReceived;
  const factory BuildingEvent.buildingUpdated(
    Building building,
  ) = BuildingUpdated;
}

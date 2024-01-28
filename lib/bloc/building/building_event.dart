part of 'building_bloc.dart';

@freezed
class BuildingEvent with _$BuildingEvent {
  const factory BuildingEvent.updatedBounds(
    LatLngBounds bounds,
  ) = _UpdatedBounds;
  const factory BuildingEvent.buildingsReceived(
    Either<ServerFailure, List<Building>> buildingsOrFailure,
  ) = _BuildingsReceived;
  const factory BuildingEvent.buildingUpdated(
    Building building,
  ) = _BuildingUpdated;
}

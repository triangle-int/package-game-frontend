part of 'building_bloc.dart';

@freezed
abstract class BuildingState with _$BuildingState {
  const factory BuildingState({
    required List<Building> buildings,
    required bool isLoading,
    required ServerFailure? failureOrNull,
  }) = _BuildingState;

  factory BuildingState.initial() => const BuildingState(
        buildings: [],
        isLoading: false,
        failureOrNull: null,
      );
}

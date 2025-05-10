part of 'build_mode_bloc.dart';

@freezed
sealed class BuildModeEvent with _$BuildModeEvent {
  const factory BuildModeEvent.enteredDestroyMode() =
      BuildModeEventEnteredDestroyMode;
  const factory BuildModeEvent.removedBuilding(int id) =
      BuildModeEventRemovedBuilding;
  const factory BuildModeEvent.exitedDestroyMode() =
      BuildModeEventExitedDestroyMode;
}

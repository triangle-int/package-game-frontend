part of 'build_mode_bloc.dart';

@freezed
class BuildModeEvent with _$BuildModeEvent {
  const factory BuildModeEvent.enteredDestroyMode() = _EnteredDestroyMode;
  const factory BuildModeEvent.removedBuilding(int id) = _RemovedBuilding;
  const factory BuildModeEvent.exitedDestroyMode() = _ExitedDestroyMode;
}

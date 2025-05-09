part of 'build_mode_bloc.dart';

@freezed
sealed class BuildModeState with _$BuildModeState {
  const factory BuildModeState.buildMode() = BuildModeStateBuildMode;
  const factory BuildModeState.destroyMode() = BuildModeStateDestroyMode;
}

part of 'build_mode_bloc.dart';

@freezed
class BuildModeState with _$BuildModeState {
  const factory BuildModeState.buildMode() = _BuildMode;
  const factory BuildModeState.destroyMode() = _DestroyMode;
}

part of 'build_panel_bloc.dart';

@freezed
class BuildPanelState with _$BuildPanelState {
  const factory BuildPanelState.initial() = _Initial;
  const factory BuildPanelState.loadInProgress() = _LoadInProgress;
  const factory BuildPanelState.loadFailure(ServerFailure failure) =
      _LoadFailure;
  const factory BuildPanelState.loadSuccess() = _LoadSuccess;
}

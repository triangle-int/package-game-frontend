part of 'build_panel_bloc.dart';

@freezed
sealed class BuildPanelState with _$BuildPanelState {
  const factory BuildPanelState.initial() = BuildPanelStateInitial;
  const factory BuildPanelState.loadInProgress() =
      BuildPanelStateLoadInProgress;
  const factory BuildPanelState.loadFailure(ServerFailure failure) =
      BuildPanelStateLoadFailure;
  const factory BuildPanelState.loadSuccess() = BuildPanelStateLoadSuccess;
}

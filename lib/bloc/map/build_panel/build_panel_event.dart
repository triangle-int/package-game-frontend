part of 'build_panel_bloc.dart';

@freezed
sealed class BuildPanelEvent with _$BuildPanelEvent {
  const factory BuildPanelEvent.buildBusiness(LatLng location) =
      BuildPanelEventBuildBusiness;
  const factory BuildPanelEvent.buildStorage(LatLng location) =
      BuildPanelEventBuildStorage;
  const factory BuildPanelEvent.buildFactory(LatLng location) =
      BuildPanelEventBuildFactory;
  const factory BuildPanelEvent.buildSatellite(LatLng location, int level) =
      BuildPanelEventBuildSatellite;
}

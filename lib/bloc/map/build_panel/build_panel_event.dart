part of 'build_panel_bloc.dart';

@freezed
class BuildPanelEvent with _$BuildPanelEvent {
  const factory BuildPanelEvent.buildBusiness(LatLng location) = _BuildBusiness;
  const factory BuildPanelEvent.buildStorage(LatLng location) = _BuildStorage;
  const factory BuildPanelEvent.buildFactory(LatLng location) = _BuildFactory;
  const factory BuildPanelEvent.buildSatellite(LatLng location, int level) =
      _BuildSatellite;
}

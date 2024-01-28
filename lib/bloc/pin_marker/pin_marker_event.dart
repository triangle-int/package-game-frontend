part of 'pin_marker_bloc.dart';

@freezed
class PinMarkerEvent with _$PinMarkerEvent {
  const factory PinMarkerEvent.markerPlaced(
    LatLng location,
    LatLng circleCenter,
    double circleRadius,
    Config config,
  ) = _MarkerPlaced;
  const factory PinMarkerEvent.markerHidden() = _MarkerHidden;
}

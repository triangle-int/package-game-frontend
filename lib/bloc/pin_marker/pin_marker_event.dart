part of 'pin_marker_bloc.dart';

@freezed
sealed class PinMarkerEvent with _$PinMarkerEvent {
  const factory PinMarkerEvent.placed(
    LatLng location,
    LatLng circleCenter,
    double circleRadius,
    Config config,
  ) = PinMarkerEventPlaced;
  const factory PinMarkerEvent.hidden() = PinMarkerEventHidden;
}

part of 'pin_marker_bloc.dart';

@freezed
class PinMarkerState with _$PinMarkerState {
  const factory PinMarkerState({
    required LatLng location,
    required bool isShown,
    required Zone cell,
  }) = _PinMarkerState;

  factory PinMarkerState.initial() => PinMarkerState(
        location: LatLng(0, 0),
        isShown: false,
        // TODO(P5ina): Get cell level from config
        cell: Zone.byLocation(0, 0, 9),
      );
}

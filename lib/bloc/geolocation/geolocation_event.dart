part of 'geolocation_bloc.dart';

@freezed
class GeolocationEvent with _$GeolocationEvent {
  const factory GeolocationEvent.listenGeolocationRequested() =
      _ListenGeolocationRequested;
  const factory GeolocationEvent.geolocationReceived(
    Either<GeolocationFailure, Position> positionOrFailure,
  ) = _GeolocationReceived;
  const factory GeolocationEvent.openAppSettings() = _OpenAppSettings;
  const factory GeolocationEvent.openLocationSettings() = _OpenLocationSettings;
  const factory GeolocationEvent.requestPermission() = _RequestPermission;
}

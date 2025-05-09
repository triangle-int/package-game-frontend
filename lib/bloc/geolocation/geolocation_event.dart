part of 'geolocation_bloc.dart';

@freezed
sealed class GeolocationEvent with _$GeolocationEvent {
  const factory GeolocationEvent.listenGeolocationRequested() =
      ListenGeolocationRequested;
  const factory GeolocationEvent.geolocationReceived(
    Either<GeolocationFailure, Position> positionOrFailure,
  ) = GeolocationReceived;
  const factory GeolocationEvent.openAppSettings() = OpenAppSettings;
  const factory GeolocationEvent.openLocationSettings() = OpenLocationSettings;
  const factory GeolocationEvent.requestPermission() = RequestPermission;
}

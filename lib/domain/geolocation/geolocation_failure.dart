import 'package:freezed_annotation/freezed_annotation.dart';

part 'geolocation_failure.freezed.dart';

@freezed
sealed class GeolocationFailure with _$GeolocationFailure {
  const factory GeolocationFailure.permissionDenied() =
      GeolocationFailurePermissionDenied;
  const factory GeolocationFailure.serviceDisabled() =
      GeolocationFailureServiceDisabled;
  const factory GeolocationFailure.permissionDeniedForever() =
      GeolocationFailurePermissionDeniedForever;
  const factory GeolocationFailure.unknown() = GeolocationFailureUnknown;
  const factory GeolocationFailure.reducedAccuracy() =
      GeolocationFailureReducedAccuracy;
  const factory GeolocationFailure.noSignal() = GeolocationFailureNoSignal;
}

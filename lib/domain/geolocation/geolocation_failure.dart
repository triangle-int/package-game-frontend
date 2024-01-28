import 'package:freezed_annotation/freezed_annotation.dart';

part 'geolocation_failure.freezed.dart';

@freezed
class GeolocationFailure with _$GeolocationFailure {
  const factory GeolocationFailure.permissionDenied() = _PermissionDenied;
  const factory GeolocationFailure.serviceDisabled() = _ServiceDisabled;
  const factory GeolocationFailure.permissionDeniedForever() =
      _PermissionDeniedForever;
  const factory GeolocationFailure.unknown() = _Unknown;
  const factory GeolocationFailure.reducedAccuracy() = _ReducedAccuracy;
  const factory GeolocationFailure.noSignal() = _NoSignal;
}

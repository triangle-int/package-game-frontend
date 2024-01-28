part of 'geolocation_bloc.dart';

@freezed
class GeolocationState with _$GeolocationState {
  const factory GeolocationState.initial() = _Initial;
  const factory GeolocationState.loadInProgress() = _LoadInProgress;
  const factory GeolocationState.loadFailure(GeolocationFailure failure) =
      _LoadFailure;
  const factory GeolocationState.loadSuccess(Position position) = _LoadSuccess;
}

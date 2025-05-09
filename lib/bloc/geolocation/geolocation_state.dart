part of 'geolocation_bloc.dart';

// TODO: Convert this to use Either
@freezed
sealed class GeolocationState with _$GeolocationState {
  const factory GeolocationState.initial() = GeolocationStateInitial;
  const factory GeolocationState.loadInProgress() =
      GeolocationStateLoadInProgress;
  const factory GeolocationState.loadFailure(GeolocationFailure failure) =
      GeolocationStateLoadFailure;
  const factory GeolocationState.loadSuccess(Position position) =
      GeolocationStateLoadSuccess;
}

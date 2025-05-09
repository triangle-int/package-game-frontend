part of 'satellite_bloc.dart';

@freezed
sealed class SatelliteEvent with _$SatelliteEvent {
  const factory SatelliteEvent.collectedMoney(int id) = CollectedMoney;
}

part of 'satellite_bloc.dart';

@freezed
class SatelliteEvent with _$SatelliteEvent {
  const factory SatelliteEvent.collectedMoney(int id) = _CollectedMoney;
}

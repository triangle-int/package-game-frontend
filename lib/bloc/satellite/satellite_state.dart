part of 'satellite_bloc.dart';

@freezed
class SatelliteState with _$SatelliteState {
  const factory SatelliteState.initial() = _Initial;
  const factory SatelliteState.loading() = _Loading;
  const factory SatelliteState.showLines(LinesAndHexes linesAndHexes) =
      _ShowLines;
}

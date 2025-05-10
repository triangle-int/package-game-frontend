part of 'satellite_bloc.dart';

@freezed
sealed class SatelliteState with _$SatelliteState {
  const factory SatelliteState.initial() = SatelliteStateInitial;
  const factory SatelliteState.loading() = SatelliteStateLoading;
  const factory SatelliteState.showLines(LinesAndHexes linesAndHexes) =
      SatelliteStateShowLines;
}

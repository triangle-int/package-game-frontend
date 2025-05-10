import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'satellite_line.freezed.dart';

@freezed
abstract class SatelliteLine with _$SatelliteLine {
  const factory SatelliteLine({
    required int fromId,
    required int toId,
    required bool showHexes,
    required LatLng start,
    required LatLng end,
  }) = _SatelliteLine;
}

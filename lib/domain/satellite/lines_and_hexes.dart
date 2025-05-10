import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geohex/geohex.dart';
import 'package:package_flutter/domain/satellite/satellite_line.dart';

part 'lines_and_hexes.freezed.dart';

@freezed
abstract class LinesAndHexes with _$LinesAndHexes {
  const factory LinesAndHexes({
    required List<SatelliteLine> lines,
    required List<Zone> firstLayer,
    required List<Zone> secondLayer,
  }) = _LinesAndHexes;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculated_path.freezed.dart';
part 'calculated_path.g.dart';

@freezed
class CalculatedPath with _$CalculatedPath {
  factory CalculatedPath({
    required int costPerTruck,
    required BigInt cost,
    required double distance,
  }) = _CalculatedPath;

  factory CalculatedPath.fromJson(Map<String, dynamic> json) =>
      _$CalculatedPathFromJson(json);
}

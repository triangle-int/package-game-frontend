import 'package:freezed_annotation/freezed_annotation.dart';

part 'booster_type.freezed.dart';
part 'booster_type.g.dart';

@freezed
abstract class BoosterTypes with _$BoosterTypes {
  const factory BoosterTypes({
    required String businessIncome,
    required String priceDecrease,
    required String deliverySpeed,
    required String factoryProduction,
  }) = _BoosterTypes;

  factory BoosterTypes.fromJson(Map<String, dynamic> json) =>
      _$BoosterTypesFromJson(json);
}

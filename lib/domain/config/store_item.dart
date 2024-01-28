import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_item.freezed.dart';
part 'store_item.g.dart';

@Freezed(unionKey: 'type')
class StoreItem with _$StoreItem {
  const factory StoreItem.iap({
    required String id,
    required String icon,
    required int amount,
    required bool isConsumable,
  }) = StoreItemIAP;

  const factory StoreItem.booster({
    required String name,
    required int amount,
    required String price,
  }) = StoreItemBooster;

  factory StoreItem.fromJson(Map<String, dynamic> json) =>
      _$StoreItemFromJson(json);
}

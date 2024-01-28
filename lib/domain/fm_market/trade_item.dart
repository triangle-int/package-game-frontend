import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/user/user.dart';

part 'trade_item.freezed.dart';
part 'trade_item.g.dart';

@freezed
class TradeItem with _$TradeItem {
  factory TradeItem({
    required int id,
    required String name,
    required BigInt count,
    required int pricePerUnit,
    required int ownerId,
    required User owner,
  }) = _TradeItem;

  factory TradeItem.fromJson(Map<String, dynamic> json) =>
      _$TradeItemFromJson(json);
}

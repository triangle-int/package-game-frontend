import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_trade.freezed.dart';
part 'my_trade.g.dart';

@freezed
abstract class MyTrade with _$MyTrade {
  const factory MyTrade({
    required int id,
    required String name,
    required BigInt count,
    required int pricePerUnit,
    required int ownerId,
    required MyTradePrice min,
    required MyTradePrice average,
  }) = _MyTrade;

  factory MyTrade.fromJson(Map<String, dynamic> json) =>
      _$MyTradeFromJson(json);
}

@freezed
abstract class MyTradePrice with _$MyTradePrice {
  const factory MyTradePrice({
    required double? pricePerUnit,
  }) = _MyTradePrice;

  factory MyTradePrice.fromJson(Map<String, dynamic> json) =>
      _$MyTradePriceFromJson(json);
}

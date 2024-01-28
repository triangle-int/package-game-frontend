part of 'buy_bloc.dart';

@freezed
class BuyEvent with _$BuyEvent {
  const factory BuyEvent.amountUpdated(BigInt newAmount) = _AmountUpdated;
  const factory BuyEvent.bought({required int tradeId}) = _Bought;
}

part of 'buy_bloc.dart';

@freezed
sealed class BuyEvent with _$BuyEvent {
  const factory BuyEvent.amountUpdated(BigInt newAmount) =
      BuyEventAmountUpdated;
  const factory BuyEvent.bought({required int tradeId}) = BuyEventBought;
}

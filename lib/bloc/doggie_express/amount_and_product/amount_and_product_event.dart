part of 'amount_and_product_bloc.dart';

@freezed
sealed class AmountAndProductEvent with _$AmountAndProductEvent {
  const factory AmountAndProductEvent.initialOpened() =
      AmountAndProductEventInitialOpened;
  const factory AmountAndProductEvent.productOpened(
    Building pointA,
    Building pointB,
    Config config,
  ) = AmountAndProductEventProductOpened;
  const factory AmountAndProductEvent.amountOpened(
    Building pointA,
    String itemName,
  ) = AmountAndProductEventAmountOpened;
}

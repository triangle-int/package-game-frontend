part of 'amount_and_product_bloc.dart';

@freezed
class AmountAndProductEvent with _$AmountAndProductEvent {
  const factory AmountAndProductEvent.initialOpened() = _InitialOpened;
  const factory AmountAndProductEvent.productOpened(
    Building pointA,
    Building pointB,
    Config config,
  ) = _ProductOpened;
  const factory AmountAndProductEvent.amountOpened(
    Building pointA,
    String itemName,
  ) = _AmountOpened;
}

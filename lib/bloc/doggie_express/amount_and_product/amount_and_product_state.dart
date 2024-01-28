part of 'amount_and_product_bloc.dart';

@freezed
class AmountAndProductState with _$AmountAndProductState {
  const factory AmountAndProductState.initial() = _Initial;
  const factory AmountAndProductState.loadInProgress() = _LoadInProgress;
  const factory AmountAndProductState.productSelectionSuccess(
    List<Item> items,
  ) = _ProductSelectionSuccess;
  const factory AmountAndProductState.productSelectionFailure(
    ServerFailure failure,
  ) = _ProductSelectionFailure;
  const factory AmountAndProductState.amountSelectionSuccess(BigInt maxAmount) =
      _AmountSelectionSuccess;
  const factory AmountAndProductState.amountSelectionFailure(
    ServerFailure failure,
  ) = _AmountSelectionFailure;
}

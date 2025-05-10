part of 'amount_and_product_bloc.dart';

@freezed
sealed class AmountAndProductState with _$AmountAndProductState {
  const factory AmountAndProductState.initial() = AmountAndProductStateInitial;
  const factory AmountAndProductState.loadInProgress() =
      AmountAndProductStateLoadInProgress;
  const factory AmountAndProductState.productSelectionSuccess(
    List<Item> items,
  ) = AmountAndProductStateProductSelectionSuccess;
  const factory AmountAndProductState.productSelectionFailure(
    ServerFailure failure,
  ) = AmountAndProductStateProductSelectionFailure;
  const factory AmountAndProductState.amountSelectionSuccess(BigInt maxAmount) =
      AmountAndProductStateAmountSelectionSuccess;
  const factory AmountAndProductState.amountSelectionFailure(
    ServerFailure failure,
  ) = AmountAndProductStateAmountSelectionFailure;
}

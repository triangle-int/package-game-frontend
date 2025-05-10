part of 'buy_bloc.dart';

@freezed
abstract class BuyState with _$BuyState {
  const factory BuyState({
    required BigInt amount,
    required bool isLoading,
    required BuyFailure? failureOrNull,
    required bool success,
  }) = _BuyState;

  factory BuyState.initial() => BuyState(
        amount: BigInt.from(0),
        isLoading: false,
        failureOrNull: null,
        success: false,
      );
}

part of 'fm_profile_bloc.dart';

@freezed
abstract class FmProfileState with _$FmProfileState {
  const factory FmProfileState({
    required List<MyTrade> trades,
    required bool isLoading,
    required bool isPriceLoading,
    required ServerFailure? failureOrNull,
  }) = _FmProfileState;

  factory FmProfileState.initial() => const FmProfileState(
        trades: [],
        isLoading: false,
        isPriceLoading: false,
        failureOrNull: null,
      );
}

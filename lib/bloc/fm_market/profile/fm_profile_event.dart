part of 'fm_profile_bloc.dart';

@freezed
sealed class FmProfileEvent with _$FmProfileEvent {
  const factory FmProfileEvent.fetchTradesRequested() =
      FmProfileEventFetchTradesRequested;
  const factory FmProfileEvent.priceChanged({
    required int tradeId,
    required int newPrice,
  }) = FmProfileEventPriceChanged;
}

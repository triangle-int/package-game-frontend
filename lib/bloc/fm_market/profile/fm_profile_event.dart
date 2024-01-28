part of 'fm_profile_bloc.dart';

@freezed
class FmProfileEvent with _$FmProfileEvent {
  const factory FmProfileEvent.fetchTradesRequested() = _FetchTradesRequested;
  const factory FmProfileEvent.priceChanged({
    required int tradeId,
    required int newPrice,
  }) = _PriceChanged;
}

part of 'market_bloc.dart';

@freezed
sealed class MarketEvent with _$MarketEvent {
  const factory MarketEvent.requested(int marketId) = MarketEventRequested;
}

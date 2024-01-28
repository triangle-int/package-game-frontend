part of 'market_bloc.dart';

@freezed
class MarketEvent with _$MarketEvent {
  const factory MarketEvent.marketRequested(int marketId) = _MarketRequested;
}

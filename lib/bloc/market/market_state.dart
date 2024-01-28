part of 'market_bloc.dart';

@freezed
class MarketState with _$MarketState {
  const factory MarketState.initial() = _Initial;
  const factory MarketState.loadInProgress() = _LoadInProgress;
  const factory MarketState.loadFailure(ServerFailure failure) = _LoadFailure;
  const factory MarketState.loadSuccess(MarketBuilding market) = _LoadSuccess;
}

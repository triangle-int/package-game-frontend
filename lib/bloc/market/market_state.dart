part of 'market_bloc.dart';

// Convert to state with Either
@freezed
sealed class MarketState with _$MarketState {
  const factory MarketState.initial() = MarketStateInitial;
  const factory MarketState.loadInProgress() = MarketStateLoadInProgress;
  const factory MarketState.loadFailure(ServerFailure failure) =
      MarketStateLoadFailure;
  const factory MarketState.loadSuccess(MarketBuilding market) =
      MarketStateLoadSuccess;
}

part of 'factory_bloc.dart';

// Change to Either
@freezed
sealed class FactoryState with _$FactoryState {
  const factory FactoryState.initial() = FactoryStateInitial;
  const factory FactoryState.loadInProgress() = FactoryStateLoadInProgress;
  const factory FactoryState.loadFailure(ServerFailure f) =
      FactoryStateLoadFailure;
  const factory FactoryState.loadSuccess(FactoryBuilding factoryBuilding) =
      FactoryStateLoadSuccess;
}

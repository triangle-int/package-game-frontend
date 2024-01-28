part of 'factory_bloc.dart';

@freezed
class FactoryState with _$FactoryState {
  const factory FactoryState.initial() = _Initial;
  const factory FactoryState.loadInProgress() = _LoadInProgress;
  const factory FactoryState.loadFailure(ServerFailure f) = _LoadFailure;
  const factory FactoryState.loadSuccess(FactoryBuilding factoryBuilding) =
      _LoadSuccess;
}

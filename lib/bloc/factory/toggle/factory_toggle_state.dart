part of 'factory_toggle_bloc.dart';

@freezed
class FactoryToggleState with _$FactoryToggleState {
  const factory FactoryToggleState.initial() = _Initial;
  const factory FactoryToggleState.loadInProgress() = _LoadInProgress;
  const factory FactoryToggleState.loadSuccess(FactoryBuilding building) =
      _LoadSuccess;
  const factory FactoryToggleState.loadFailure(ServerFailure f) = _LoadFailure;
}

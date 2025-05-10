part of 'factory_toggle_bloc.dart';

@freezed
sealed class FactoryToggleState with _$FactoryToggleState {
  const factory FactoryToggleState.initial() = FactoryToggleStateInitial;
  const factory FactoryToggleState.loadInProgress() =
      FactoryToggleStateLoadInProgress;
  const factory FactoryToggleState.loadSuccess(FactoryBuilding building) =
      FactoryToggleStateLoadSuccess;
  const factory FactoryToggleState.loadFailure(ServerFailure f) =
      FactoryToggleStateLoadFailure;
}

part of 'factory_bloc.dart';

@freezed
class FactoryEvent with _$FactoryEvent {
  const factory FactoryEvent.factoryRequested(int factoryId) =
      _FactoryRequested;
  const factory FactoryEvent.factoryGot(FactoryBuilding factoryBuilding) =
      _FactoryGot;
}

part of 'factory_bloc.dart';

@freezed
sealed class FactoryEvent with _$FactoryEvent {
  const factory FactoryEvent.factoryRequested(int factoryId) =
      FactoryEventFactoryRequested;
  const factory FactoryEvent.factoryGot(FactoryBuilding factoryBuilding) =
      FactoryEventFactoryGot;
}

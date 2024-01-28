part of 'factory_toggle_bloc.dart';

@freezed
class FactoryToggleEvent with _$FactoryToggleEvent {
  const factory FactoryToggleEvent.factoryToggled(FactoryBuilding building) =
      _FactoryToggled;
}

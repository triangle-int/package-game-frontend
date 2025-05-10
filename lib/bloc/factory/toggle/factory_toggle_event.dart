part of 'factory_toggle_bloc.dart';

@freezed
sealed class FactoryToggleEvent with _$FactoryToggleEvent {
  const factory FactoryToggleEvent.toggled(FactoryBuilding building) =
      FactoryToggleEventToggled;
}

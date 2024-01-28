part of 'factory_upgrade_bloc.dart';

@freezed
class FactoryUpgradeEvent with _$FactoryUpgradeEvent {
  const factory FactoryUpgradeEvent.factoryUpgraded(
    FactoryBuilding factoryBuilding,
  ) = _FactoryUpgraded;
}

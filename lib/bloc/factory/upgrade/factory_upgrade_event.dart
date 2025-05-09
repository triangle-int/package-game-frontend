part of 'factory_upgrade_bloc.dart';

@freezed
sealed class FactoryUpgradeEvent with _$FactoryUpgradeEvent {
  const factory FactoryUpgradeEvent.factoryUpgraded(
    FactoryBuilding factoryBuilding,
  ) = FactoryUpgradeEventFactoryUpgraded;
}

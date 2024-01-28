part of 'business_upgrade_bloc.dart';

@freezed
class BusinessUpgradeEvent with _$BusinessUpgradeEvent {
  const factory BusinessUpgradeEvent.upgradeRequested(
      BusinessBuilding building,) = _UpgradeRequested;
}

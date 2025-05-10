part of 'business_upgrade_bloc.dart';

@freezed
sealed class BusinessUpgradeEvent with _$BusinessUpgradeEvent {
  const factory BusinessUpgradeEvent.upgradeRequested(
    BusinessBuilding building,
  ) = UpgradeRequested;
}

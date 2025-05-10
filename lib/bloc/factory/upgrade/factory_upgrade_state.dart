part of 'factory_upgrade_bloc.dart';

@freezed
sealed class FactoryUpgradeState with _$FactoryUpgradeState {
  const factory FactoryUpgradeState.initial() = FactoryUpgradeStateInitial;
  const factory FactoryUpgradeState.loadInProgress() =
      FactoryUpgradeStateLoadInProgress;
  const factory FactoryUpgradeState.loadSuccess(FactoryBuilding building) =
      FactoryUpgradeStateLoadSuccess;
  const factory FactoryUpgradeState.loadFailure(ServerFailure failure) =
      FactoryUpgradeStateLoadFailure;
}

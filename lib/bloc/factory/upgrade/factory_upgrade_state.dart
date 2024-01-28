part of 'factory_upgrade_bloc.dart';

@freezed
class FactoryUpgradeState with _$FactoryUpgradeState {
  const factory FactoryUpgradeState.initial() = _Initial;
  const factory FactoryUpgradeState.loadInProgress() = _LoadInProgress;
  const factory FactoryUpgradeState.loadSuccess(FactoryBuilding building) =
      _LoadSuccess;
  const factory FactoryUpgradeState.loadFailure(ServerFailure failure) =
      _LoadFailure;
}

part of 'business_upgrade_bloc.dart';

@freezed
class BusinessUpgradeState with _$BusinessUpgradeState {
  const factory BusinessUpgradeState.initial() = _Initial;
  const factory BusinessUpgradeState.loadInProgress() = _LoadInProgress;
  const factory BusinessUpgradeState.loadFailure(ServerFailure failure) =
      _LoadFailure;
  const factory BusinessUpgradeState.loadSuccess(
    BusinessBuilding building,
  ) = _LoadSuccess;
}

part of 'business_upgrade_bloc.dart';

@freezed
sealed class BusinessUpgradeState with _$BusinessUpgradeState {
  const factory BusinessUpgradeState.initial() = Initial;
  const factory BusinessUpgradeState.loadInProgress() = LoadInProgress;
  const factory BusinessUpgradeState.loadFailure(ServerFailure failure) =
      LoadFailure;
  const factory BusinessUpgradeState.loadSuccess(
    BusinessBuilding building,
  ) = LoadSuccess;
}

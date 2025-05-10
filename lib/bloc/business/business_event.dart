part of 'business_bloc.dart';

@freezed
sealed class BusinessEvent with _$BusinessEvent {
  const factory BusinessEvent.businessRequested(int businessId, User user) =
      BusinessRequested;
  const factory BusinessEvent.collectMoney(User user) = CollectMoney;
  const factory BusinessEvent.businessGot(BusinessBuilding businessBuilding) =
      BusinessGot;
}

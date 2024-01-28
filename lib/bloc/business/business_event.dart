part of 'business_bloc.dart';

@freezed
class BusinessEvent with _$BusinessEvent {
  const factory BusinessEvent.businessRequested(int businessId, User user) =
      _BusinessRequested;
  const factory BusinessEvent.collectMoney(User user) = _CollectMoney;
  const factory BusinessEvent.businessGot(BusinessBuilding businessBuilding) =
      _BusinessGot;
}

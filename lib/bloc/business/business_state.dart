part of 'business_bloc.dart';

@freezed
sealed class BusinessState with _$BusinessState {
  const factory BusinessState.initial() = BusinessStateInitial;
  const factory BusinessState.loadInProgress() = BusinessStateLoadInProgress;
  const factory BusinessState.loadFailure(ServerFailure failure) =
      BusinessStateLoadFailure;
  const factory BusinessState.loadSuccess(GetBusinessResponse businessAndTax) =
      BusinessStateLoadSuccess;
}

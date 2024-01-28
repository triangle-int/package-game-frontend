part of 'business_bloc.dart';

@freezed
class BusinessState with _$BusinessState {
  const factory BusinessState.initial() = _Initial;
  const factory BusinessState.loadInProgress() = _LoadInProgress;
  const factory BusinessState.loadFailure(ServerFailure failure) = _LoadFailure;
  const factory BusinessState.loadSuccess(GetBusinessResponse businessAndTax) =
      _LoadSuccess;
}

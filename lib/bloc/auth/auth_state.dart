part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loadInProgress() = LoadInProgress;
  const factory AuthState.loadFailure(AuthFailure failure) = LoadFailure;
  const factory AuthState.loadSuccess(User user) = LoadSuccess;
}

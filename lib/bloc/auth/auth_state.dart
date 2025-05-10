part of 'auth_bloc.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loadInProgress() = AuthStateLoadInProgress;
  const factory AuthState.loadFailure(AuthFailure failure) =
      AuthStateLoadFailure;
  const factory AuthState.loadSuccess(User user) = AuthStateLoadSuccess;
}

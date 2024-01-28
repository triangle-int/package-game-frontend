part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.listenAuthStatusRequested() =
      _ListenAuthStatusRequested;
  const factory AuthEvent.signedOut() = _SignedOut;
  const factory AuthEvent.authStatusReceived(
    Either<AuthFailure, User> userOrFailure,
  ) = _AuthStatusReceived;
}

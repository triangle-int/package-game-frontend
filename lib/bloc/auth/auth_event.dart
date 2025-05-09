part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.listenAuthStatusRequested() =
      ListenAuthStatusRequested;
  const factory AuthEvent.signedOut() = SignedOut;
  const factory AuthEvent.authStatusReceived(
    Either<AuthFailure, User> userOrFailure,
  ) = AuthStatusReceived;
}

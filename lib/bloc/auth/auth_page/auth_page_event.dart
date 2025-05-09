part of 'auth_page_bloc.dart';

@freezed
sealed class AuthPageEvent with _$AuthPageEvent {
  const factory AuthPageEvent.signedInWithGoogle() = SignedInWithGoogle;
  const factory AuthPageEvent.signedInWithApple() = SignedInWithApple;
}

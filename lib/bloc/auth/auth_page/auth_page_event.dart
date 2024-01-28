part of 'auth_page_bloc.dart';

@freezed
class AuthPageEvent with _$AuthPageEvent {
  const factory AuthPageEvent.signedInWithGoogle() = _SignedInWithGoogle;
  const factory AuthPageEvent.signedInWithApple() = _SignedInWithApple;
}

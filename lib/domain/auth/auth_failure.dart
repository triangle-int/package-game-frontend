import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.unauthenticated() = _Unauthenticated;
  const factory AuthFailure.canceled() = _Canceled;
  const factory AuthFailure.firebaseFailure(String message) = _FirebaseFailure;
  const factory AuthFailure.unknown() = _Unknown;
}

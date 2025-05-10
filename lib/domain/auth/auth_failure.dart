import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.unauthenticated() = Unauthenticated;
  const factory AuthFailure.canceled() = Canceled;
  const factory AuthFailure.firebaseFailure(String message) = FirebaseFailure;
  const factory AuthFailure.unknown() = Unknown;
}

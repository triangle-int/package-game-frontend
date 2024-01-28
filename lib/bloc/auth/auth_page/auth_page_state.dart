part of 'auth_page_bloc.dart';

@freezed
class AuthPageState with _$AuthPageState {
  const factory AuthPageState({
    required bool isSubmitting,
    required AuthFailure? failureOrNull,
  }) = _AuthPageState;

  factory AuthPageState.initial() => const AuthPageState(
        isSubmitting: false,
        failureOrNull: null,
      );
}

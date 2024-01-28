part of 'create_user_bloc.dart';

@freezed
class CreateUserState with _$CreateUserState {
  const factory CreateUserState({
    required String nickname,
    required String avatar,
    required bool isSubmitting,
    required CreateUserFailure? failureOrNull,
  }) = _CreateUserState;

  factory CreateUserState.initial() => const CreateUserState(
        nickname: '',
        avatar: '',
        isSubmitting: false,
        failureOrNull: null,
      );
}

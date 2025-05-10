part of 'create_user_bloc.dart';

@freezed
sealed class CreateUserEvent with _$CreateUserEvent {
  const factory CreateUserEvent.nicknameChanged(String nickname) =
      CreateUserEventNicknameChanged;
  const factory CreateUserEvent.avatarChanged(String avatar) =
      CreateUserEventAvatarChanged;
  const factory CreateUserEvent.confirmed() = CreateUserEventConfirmed;
}

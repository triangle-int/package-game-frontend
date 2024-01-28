part of 'create_user_bloc.dart';

@freezed
class CreateUserEvent with _$CreateUserEvent {
  const factory CreateUserEvent.nicknameChanged(String nickname) =
      _NicknameChanged;
  const factory CreateUserEvent.avatarChanged(String avatar) = _AvatarChanged;
  const factory CreateUserEvent.confirmed() = _Confirmed;
}

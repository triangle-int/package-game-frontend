import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user_failure.freezed.dart';

@freezed
class CreateUserFailure with _$CreateUserFailure {
  const factory CreateUserFailure.tooShortNickname(int minSize) =
      _TooShortNickname;
  const factory CreateUserFailure.tooLongNickname(int maxSize) =
      _TooLongNickname;
  const factory CreateUserFailure.invalidNickname() = _InvalidNickname;
  const factory CreateUserFailure.invalidAccessToken() = _InvalidAccessToken;
  const factory CreateUserFailure.noAvatar() = _NoAvatar;
  const factory CreateUserFailure.nicknameAlreadyInUse() =
      _NicknameAlreadyInUse;
  const factory CreateUserFailure.serverFailure(String message) =
      _ServerFailure;
}

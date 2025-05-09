import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user_failure.freezed.dart';

@freezed
sealed class CreateUserFailure with _$CreateUserFailure {
  const factory CreateUserFailure.tooShortNickname(int minSize) =
      TooShortNickname;
  const factory CreateUserFailure.tooLongNickname(int maxSize) =
      TooLongNickname;
  const factory CreateUserFailure.invalidNickname() = InvalidNickname;
  const factory CreateUserFailure.invalidAccessToken() = InvalidAccessToken;
  const factory CreateUserFailure.noAvatar() = NoAvatar;
  const factory CreateUserFailure.nicknameAlreadyInUse() = NicknameAlreadyInUse;
  const factory CreateUserFailure.serverFailure(String message) = ServerFailure;
}

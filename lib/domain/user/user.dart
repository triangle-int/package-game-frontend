import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String firebaseId,
    required String nickname,
    required String avatar,
    required BigInt money,
    required BigInt gems,
    required int level,
    required BigInt experience,
  }) = _User;

  factory User.empty() => User(
        id: 0,
        firebaseId: '',
        nickname: 'Loading',
        avatar: '🔁',
        money: BigInt.from(0),
        gems: BigInt.from(0),
        level: 0,
        experience: BigInt.from(0),
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

import 'package:flutter/foundation.dart';

@immutable
class BuildingOwner {
  const BuildingOwner({
    required this.id,
    required this.nickname,
    required this.avatar,
  });

  final int id;
  final String nickname;
  final String avatar;

  factory BuildingOwner.fromJson(Map<String, dynamic> json) => BuildingOwner(
        id: json['id'] as int,
        nickname: json['nickname'] as String,
        avatar: json['avatar'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'avatar': avatar,
      };
}

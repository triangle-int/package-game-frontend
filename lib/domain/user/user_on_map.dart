import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_on_map.freezed.dart';
part 'user_on_map.g.dart';

@freezed
class UserOnMap with _$UserOnMap {
  const factory UserOnMap({
    required String avatar,
    required String geohash,
  }) = _UserOnMap;

  factory UserOnMap.fromJson(Map<String, dynamic> json) =>
      _$UserOnMapFromJson(json);
}

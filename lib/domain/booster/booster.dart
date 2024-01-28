import 'package:freezed_annotation/freezed_annotation.dart';

part 'booster.freezed.dart';
part 'booster.g.dart';

@freezed
class Booster with _$Booster {
  const factory Booster({
    required int id,
    required DateTime endsAt,
    required String type,
  }) = _Booster;

  factory Booster.fromJson(Map<String, dynamic> json) =>
      _$BoosterFromJson(json);
}

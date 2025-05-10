import 'package:freezed_annotation/freezed_annotation.dart';

part 'ban.freezed.dart';
part 'ban.g.dart';

@freezed
abstract class Ban with _$Ban {
  const factory Ban({
    required String reason,
  }) = _Ban;

  factory Ban.fromJson(Map<String, dynamic> json) => _$BanFromJson(json);
}

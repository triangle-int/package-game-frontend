import 'package:freezed_annotation/freezed_annotation.dart';

part 'emoji.freezed.dart';
part 'emoji.g.dart';

@freezed
class Emoji with _$Emoji {
  const factory Emoji({
    required String unified,
    @JsonKey(name: 'non_qualified') String? nonQualified,
    required String image,
    @Default('')
    @JsonKey(includeFromJson: false, includeToJson: false)
    String imageUrlMedium,
    @Default('')
    @JsonKey(includeFromJson: false, includeToJson: false)
    String imageUrlHigh,
  }) = _Emoji;

  factory Emoji.fromJson(Map<String, dynamic> json) => _$EmojiFromJson(json);
}

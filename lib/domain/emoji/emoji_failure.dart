import 'package:freezed_annotation/freezed_annotation.dart';

part 'emoji_failure.freezed.dart';

@freezed
class EmojiFailure with _$EmojiFailure {
  const factory EmojiFailure.unexpected(String message) = _Unexpected;
}

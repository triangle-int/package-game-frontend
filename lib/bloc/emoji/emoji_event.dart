part of 'emoji_bloc.dart';

@freezed
class EmojiEvent with _$EmojiEvent {
  const factory EmojiEvent.emojisRequested() = _EmojisRequested;
}

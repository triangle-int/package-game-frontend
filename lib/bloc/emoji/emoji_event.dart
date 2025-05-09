part of 'emoji_bloc.dart';

@freezed
sealed class EmojiEvent with _$EmojiEvent {
  const factory EmojiEvent.emojisRequested() = EmojiEventEmojisRequested;
}

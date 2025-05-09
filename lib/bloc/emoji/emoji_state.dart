part of 'emoji_bloc.dart';

@freezed
sealed class EmojiState with _$EmojiState {
  const EmojiState._();

  const factory EmojiState.initial() = EmojiStateInitial;
  const factory EmojiState.loadInProgress() = EmojiStateLoadInProgress;
  const factory EmojiState.loadFailure(EmojiFailure failure) =
      EmojiStateLoadFailure;
  const factory EmojiState.loadSuccess(List<Emoji> emojis) =
      EmojiStateLoadSuccess;

  Emoji getEmoji(String emoji) {
    final unicode = emojiToUnicode(emoji);

    return switch (this) {
      EmojiStateInitial() => throw const UnexpectedValueError(),
      EmojiStateLoadInProgress() => throw const UnexpectedValueError(),
      EmojiStateLoadFailure() => throw const UnexpectedValueError(),
      EmojiStateLoadSuccess(:final emojis) => emojis.firstWhere(
          (e) => e.image.startsWith(unicode),
          orElse: () =>
              Emoji(unified: unicode.toUpperCase(), image: '$unicode.png'),
        ),
    };
  }
}

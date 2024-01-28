part of 'emoji_bloc.dart';

@freezed
class EmojiState with _$EmojiState {
  const EmojiState._();

  const factory EmojiState.initial() = _Initial;
  const factory EmojiState.loadInProgress() = _LoadInProgress;
  const factory EmojiState.loadFailure(EmojiFailure failure) = _LoadFailure;
  const factory EmojiState.loadSuccess(List<Emoji> emojis) = _LoadSuccess;

  Emoji getEmoji(String emoji) {
    final unicode = emojiToUnicode(emoji);

    return map(
      initial: (_) => throw const UnexpectedValueError(),
      loadInProgress: (_) => throw const UnexpectedValueError(),
      loadFailure: (_) => throw const UnexpectedValueError(),
      loadSuccess: (s) => s.emojis.firstWhere(
        (e) => e.image.startsWith(unicode),
        orElse: () =>
            Emoji(unified: unicode.toUpperCase(), image: '$unicode.png'),
      ),
    );
  }
}

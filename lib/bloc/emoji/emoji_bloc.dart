import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/data/emoji/utils.dart';
import 'package:package_flutter/domain/emoji/emoji.dart';
import 'package:package_flutter/domain/emoji/emoji_failure.dart';
import 'package:package_flutter/domain/emoji/emoji_repository.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';

part 'emoji_event.dart';
part 'emoji_state.dart';
part 'emoji_bloc.freezed.dart';

class EmojiBloc extends Bloc<EmojiEvent, EmojiState> {
  final EmojiRepository _repository;

  EmojiBloc(this._repository) : super(const EmojiState.initial()) {
    on<EmojiEvent>((event, emit) async {
      switch (event) {
        case EmojiEventEmojisRequested():
          emit(const EmojiState.loadInProgress());
          final emojisOrFailure = await _repository.loadEmojis();
          emit(
            emojisOrFailure.fold(
              (f) => EmojiState.loadFailure(f),
              (emojis) => EmojiState.loadSuccess(emojis),
            ),
          );
      }
    });
  }
}

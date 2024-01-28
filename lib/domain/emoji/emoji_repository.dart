import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/emoji/emoji.dart';
import 'package:package_flutter/domain/emoji/emoji_failure.dart';

final emojiRepositoryProvider = Provider((ref) => EmojiRepository());

class EmojiRepository {
  Future<Either<EmojiFailure, List<Emoji>>> loadEmojis() async {
    try {
      final emojiDataRaw =
          await rootBundle.loadString('assets/config/emoji.json');
      final json = jsonDecode(emojiDataRaw) as List<dynamic>;
      final emojiData = json
          .map((e) => Emoji.fromJson(e as Map<String, dynamic>))
          .map(
            (e) => e.copyWith(
              imageUrlHigh: _makeEmojiImageUrl(e.image),
              imageUrlMedium: _makeEmojiImageUrl(e.image),
            ),
          )
          .toList();

      return right(emojiData);
    } catch (e) {
      return left(EmojiFailure.unexpected(e.toString()));
    }
  }

  String _makeEmojiImageUrl(String image, {bool mediumQuality = false}) {
    const baseUrl =
        'https://raw.githubusercontent.com/iamcal/emoji-data/master';
    String platformFolder;
    if (Platform.isIOS || kDebugMode) {
      if (mediumQuality) {
        platformFolder = 'img-apple-64';
      } else {
        platformFolder = 'img-apple-160';
      }
    } else {
      if (mediumQuality) {
        platformFolder = 'img-google-64';
      } else {
        platformFolder = 'img-google-136';
      }
    }
    return '$baseUrl/$platformFolder/$image';
  }
}

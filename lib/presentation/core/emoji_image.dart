// TODO(P5ina): Emoji image with placeholder and quality settings

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';

class EmojiImage extends StatelessWidget {
  final String emoji;
  final double? size;
  final Color? color;

  const EmojiImage({
    super.key,
    required this.emoji,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojiBloc, EmojiState>(
      builder: (context, emojiState) {
        final emojiFound = emojiState.getEmoji(emoji);
        return CachedNetworkImage(
          color: color,
          colorBlendMode: BlendMode.modulate,
          width: size,
          height: size,
          fadeInDuration: Duration.zero,
          imageUrl: emojiFound.imageUrlHigh,
          errorWidget: (ctx, url, error) => Column(
            children: [
              Text(
                emojiFound.image,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
    Widget fallback() => SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              emoji,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: size == null ? null : size! * .8, height: 1),
            ),
          ),
        );

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
          placeholder: (_, __) => fallback(),
          errorWidget: (_, __, ___) => fallback(),
        );
      },
    );
  }
}

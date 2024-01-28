import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';

class BuildPanelItem extends StatelessWidget {
  const BuildPanelItem({
    super.key,
    required this.emoji,
    required this.canBuild,
    required this.onPressed,
    required this.price,
  });

  final String emoji;
  final bool canBuild;
  final Function() onPressed;
  final int price;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojiBloc, EmojiState>(
      builder: (context, emojiState) {
        return BlocBuilder<PinMarkerBloc, PinMarkerState>(
          builder: (context, pinMarkerState) {
            return SizedBox(
              width: 100,
              height: double.infinity,
              child: ElevatedButtonTheme(
                data: Theme.of(context).elevatedButtonTheme,
                child: ElevatedButton(
                  onPressed: canBuild ? () => onPressed() : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    backgroundColor: canBuild
                        ? const Color(0xFFFFB800)
                        : const Color(0xFF9F7300),
                    padding: EdgeInsets.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        EmojiImage(
                          emoji: emoji,
                          size: 80,
                        ),
                        const Spacer(),
                        Text(
                          price == 0 ? 'destroy' : '${price.toCurrency()} 💵',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

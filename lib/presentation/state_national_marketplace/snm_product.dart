import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/state_national_marketplace/help_dialog.dart';

class SNMProduct extends StatelessWidget {
  const SNMProduct({
    super.key,
    required this.icon,
    required this.amount,
    required this.price,
    required this.description,
    required this.onPressed,
    required this.isLoading,
  });

  final bool isLoading;
  final String icon;
  final int amount;
  final String description;
  final String price;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        right: 15,
        left: 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => HelpDialog(text: description),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              backgroundColor: Colors.white, // <-- Button color
            ),
            child: const Icon(
              Icons.question_mark,
              size: 24,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            '$amount x',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 7),
          EmojiImage(emoji: icon, size: 45),
          const Spacer(),
          if (!isLoading)
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                backgroundColor: const Color(0xFF373EBA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          if (isLoading)
            const CircularProgressIndicator(
              color: Color(0xFF373EBA),
            ),
        ],
      ),
    );
  }
}

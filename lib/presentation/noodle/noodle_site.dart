import 'package:flutter/material.dart';

class NoodleSite extends StatelessWidget {
  final String title;
  final String description;
  final String link;
  final Function()? onPressed;

  const NoodleSite({
    super.key,
    required this.title,
    required this.description,
    required this.link,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5, right: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            link,
            style: const TextStyle(
              fontFamily: 'Mukta Mahee',
              fontSize: 18,
              color: Color(0xFF5B5B5B),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Mukta Mahee',
                fontSize: 32,
                height: 1.2,
                color: Color(0xFF373EBA),
                decoration: TextDecoration.underline,
                decorationThickness: 3,
              ),
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Mukta Mahee',
              fontSize: 16,
              color: Color(0xFF5B5B5B),
            ),
          )
        ],
      ),
    );
  }
}

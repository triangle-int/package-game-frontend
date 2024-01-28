import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final Function()? onTap;
  final String emoji;
  final String text;

  const SidebarItem({
    super.key,
    required this.emoji,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '$emoji $text',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
      ),
      onTap: onTap,
    );
  }
}

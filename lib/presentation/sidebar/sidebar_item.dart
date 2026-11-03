import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:package_flutter/l10n/translations.dart';

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
      title: AppText(
        '$emoji ${translate(context, text)}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
      ),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const AuthButton(
    this.text, {
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(367, 88),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(130),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
    );
  }
}

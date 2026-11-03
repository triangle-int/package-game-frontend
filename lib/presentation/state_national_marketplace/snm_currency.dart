import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';

class SNMCurrency extends StatelessWidget {
  const SNMCurrency({
    super.key,
    required this.currency,
  });

  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        currency,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}

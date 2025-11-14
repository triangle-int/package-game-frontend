import 'package:flutter/material.dart';

class FMMarketLogo extends StatelessWidget {
  const FMMarketLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE088),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/ui/fm_market_logo.png',
      ),
    );
  }
}

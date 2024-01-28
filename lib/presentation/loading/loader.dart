import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: RiveAnimation.asset('assets/animations/loader.riv'),
    );
  }
}

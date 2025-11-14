import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NewLevelDialog extends StatelessWidget {
  const NewLevelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, -0.5),
            child: Lottie.asset(
              'assets/animations/confetti.json',
              width: 334,
              height: 203,
              fit: BoxFit.cover,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Container(
              width: 334,
              height: 203,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Column(
                children: [
                  Text(
                    'Congratulations!',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

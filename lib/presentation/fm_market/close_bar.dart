import 'package:flutter/material.dart';

class CloseBar extends StatelessWidget {
  const CloseBar({super.key, required this.showMoney});

  final bool showMoney;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      // child: Center(
      //   child: IconButton(
      //     onPressed: () => context.router.pop(),
      //     color: Colors.black,
      //     iconSize: 30,
      //     icon: const Icon(Icons.close),
      //   ),
      // ),
    );
  }
}

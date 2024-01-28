import 'package:flutter/material.dart';

class PackageTitle extends StatelessWidget {
  final Widget child;

  const PackageTitle({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          const Text(
            'Package',
            style: TextStyle(
              fontFamily: 'Sansation',
              fontSize: 54,
            ),
          ),
          const SizedBox(height: 8),
          const Image(
            image: AssetImage('assets/images/ui/package_logo.png'),
            height: 120,
          ),
          const Spacer(),
          child,
          const Spacer(),
        ],
      ),
    );
  }
}

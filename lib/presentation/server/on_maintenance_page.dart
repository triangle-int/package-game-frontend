import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/core/package_title.dart';

class OnMaintenancePage extends StatelessWidget {
  const OnMaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: PackageTitle(
          child: Text(
            'On Maintenance',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

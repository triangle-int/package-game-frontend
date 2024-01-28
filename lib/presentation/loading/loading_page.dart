import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_flutter/presentation/loading/loader.dart';

class LoadingPage extends StatelessWidget {
  final String text;

  const LoadingPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, //or set color with: Color(0xFF0000FF)
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Loader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

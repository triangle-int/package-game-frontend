import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package/main/app.dart';
import 'package:package/main/riverpod_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      observers: [RiverpodObserver()],
      child: MyApp(),
    ),
  );
}

import 'package:logger/logger.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/config/config_repository.dart';
import 'package:package_flutter/domain/core/firebase_auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_provider.g.dart';

@riverpod
Future<Config> config(ConfigRef ref) async {
  await ref
      .watch(firebaseAuthProvider)
      .userChanges()
      .where((e) => e != null)
      .first;
  Logger().d('Config requested 🔁');
  final result = await ref.watch(configRepositoryProvider).getConfig();
  return result;
}

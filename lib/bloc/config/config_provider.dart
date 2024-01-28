import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/config/config_repository.dart';
import 'package:package_flutter/domain/core/firebase_auth_provider.dart';

final configProvider = FutureProvider((ref) async {
  await ref
      .watch(firebaseAuthProvider)
      .userChanges()
      .where((e) => e != null)
      .first;
  Logger().d('Config requested 🔁');
  final result = await ref.watch(configRepositoryProvider).getConfig();
  return result;
});

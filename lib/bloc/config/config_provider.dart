import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/config/config_repository.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_provider.g.dart';

@riverpod
Future<Config> config(Ref ref) async {
  await ref.watch(authRepositoryProvider).authStateChanges().firstWhere(
        (state) => state.isRight(),
      );
  Logger().d('Config requested 🔁');
  final result = await ref.watch(configRepositoryProvider).getConfig();
  return result;
}

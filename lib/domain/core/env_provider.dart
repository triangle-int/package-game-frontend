import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/core/env/env_production.dart';
import 'package:package_flutter/domain/core/env/env_staging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'env_provider.g.dart';

@riverpod
String environment(Ref ref) {
  return const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: kDebugMode ? Env.stagingEnviroment : Env.productionEnviroment,
  );
}

@riverpod
Env env(Ref ref) {
  switch (ref.watch(environmentProvider)) {
    case Env.productionEnviroment:
      return EnvProduction();
    case Env.stagingEnviroment:
      return EnvStaging();
    default:
      return EnvProduction();
  }
}

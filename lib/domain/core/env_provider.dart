import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/core/env/env_production.dart';
import 'package:package_flutter/domain/core/env/env_staging.dart';

final environmentProvider = Provider(
  (ref) => const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: kDebugMode ? Env.stagingEnviroment : Env.productionEnviroment,
  ),
);

final envProvider = Provider((ref) {
  switch (ref.watch(environmentProvider)) {
    case Env.productionEnviroment:
      return EnvProduction();
    case Env.stagingEnviroment:
      return EnvStaging();
    default:
      return EnvProduction();
  }
});

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/core/env/env_production.dart';
import 'package:package_flutter/domain/core/env/env_staging.dart';

final environmentProvider = Provider(
  (ref) => const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: kDebugMode ? Env.STAGING : Env.PROD,
  ),
);

final envProvider = Provider((ref) {
  switch (ref.watch(environmentProvider)) {
    case Env.PROD:
      return EnvProduction();
    case Env.STAGING:
      return EnvStaging();
    default:
      return EnvProduction();
  }
});

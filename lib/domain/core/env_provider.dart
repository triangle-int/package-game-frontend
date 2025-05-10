import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'env_provider.g.dart';

@riverpod
Env env(Ref ref) {
  return Env(
    serverUrl: dotenv.env['SERVER_URL']!,
    mapAccessKey: dotenv.env['MAP_ACCESS_KEY']!,
    mapDarkUrl: dotenv.env['MAP_DARK_URL']!,
    mapWhiteUrl: dotenv.env['MAP_WHITE_URL']!,
    wiredashSecretToken: dotenv.env['WIREDASH_SECRET_TOKEN']!,
    wiredashProjectId: dotenv.env['WIREDASH_PROJECT_ID']!,
    serverCertificate: dotenv.env['SERVER_CERTIFICATE']!,
  );
}

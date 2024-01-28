import 'package:envied/envied.dart';
import 'package:package_flutter/domain/core/env/env.dart';

part 'env_staging.g.dart';

@Envied(obfuscate: true, path: '.env.staging')
class EnvStaging implements Env {
  @override
  @EnviedField(varName: 'SERVER_URL')
  final serverUrl = _EnvStaging.serverUrl;

  @override
  @EnviedField(varName: 'MAP_ACCESS_KEY')
  final mapAccessKey = _EnvStaging.mapAccessKey;

  @override
  @EnviedField(varName: 'MAP_URL_DARK')
  final mapDarkUrl = _EnvStaging.mapDarkUrl;

  @override
  @EnviedField(varName: 'MAP_URL_WHITE')
  final mapWhiteUrl = _EnvStaging.mapWhiteUrl;

  @override
  @EnviedField(varName: 'WIREDASH_SECRET_TOKEN')
  final wiredashSecretToken = _EnvStaging.wiredashSecretToken;

  @override
  @EnviedField(varName: 'WIREDASH_PROJECT_ID')
  final wiredashProjectId = _EnvStaging.wiredashProjectId;

  @override
  @EnviedField(varName: 'SERVER_CERTIFICATE')
  final serverCertificate = _EnvStaging.serverCertificate;
}

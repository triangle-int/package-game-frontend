import 'package:envied/envied.dart';
import 'package:package_flutter/domain/core/env/env.dart';

part 'env_production.g.dart';

@Envied(obfuscate: false, path: '.env.production')
class EnvProduction implements Env {
  @override
  @EnviedField(varName: 'SERVER_URL')
  final serverUrl = _EnvProduction.serverUrl;

  @override
  @EnviedField(varName: 'MAP_ACCESS_KEY')
  final mapAccessKey = _EnvProduction.mapAccessKey;

  @override
  @EnviedField(varName: 'MAP_URL_DARK')
  final mapDarkUrl = _EnvProduction.mapDarkUrl;

  @override
  @EnviedField(varName: 'MAP_URL_WHITE')
  final mapWhiteUrl = _EnvProduction.mapWhiteUrl;

  @override
  @EnviedField(varName: 'WIREDASH_SECRET_TOKEN')
  final wiredashSecretToken = _EnvProduction.wiredashSecretToken;

  @override
  @EnviedField(varName: 'WIREDASH_PROJECT_ID')
  final wiredashProjectId = _EnvProduction.wiredashProjectId;

  @override
  @EnviedField(varName: 'SERVER_CERTIFICATE')
  final serverCertificate = _EnvProduction.serverCertificate;
}

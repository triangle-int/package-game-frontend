import 'package:freezed_annotation/freezed_annotation.dart';

part 'env.freezed.dart';

@freezed
abstract class Env with _$Env {
  const factory Env({
    required String serverUrl,
    required String mapAccessKey,
    required String mapDarkUrl,
    required String mapWhiteUrl,
    required String wiredashSecretToken,
    required String wiredashProjectId,
    required String serverCertificate,
  }) = _Env;

  static const String stagingEnvironment = 'STAGING';
  static const String productionEnvironment = 'PROD';
}

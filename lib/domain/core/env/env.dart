abstract class Env {
  abstract final String serverUrl;
  abstract final String mapAccessKey;
  abstract final String mapDarkUrl;
  abstract final String mapWhiteUrl;
  abstract final String wiredashSecretToken;
  abstract final String wiredashProjectId;
  abstract final String serverCertificate;

  static const String STAGING = 'STAGING';
  static const String PROD = 'PROD';
}

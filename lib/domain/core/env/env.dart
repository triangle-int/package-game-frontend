import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static String getServerUrl() {
    return dotenv.env['SERVER_URL'] ?? '';
  }

  static String getMapAccessKey() {
    return dotenv.env['MAP_ACCESS_KEY'] ?? '';
  }

  static String getMapDarkUrl() {
    return dotenv.env['MAP_URL_DARK'] ?? '';
  }

  static String getMapWhiteUrl() {
    return dotenv.env['MAP_URL_WHITE'] ?? '';
  }

  static String getWiredashSecretToken() {
    return dotenv.env['WIREDASH_SECRET_TOKEN'] ?? '';
  }

  static String getWiredashProjectId() {
    return dotenv.env['WIREDASH_PROJECT_ID'] ?? '';
  }

  static String getServerCertificate() {
    return dotenv.env['SERVER_CERTIFICATE'] ?? '';
  }

  static const String stagingEnvironment = 'STAGING';
  static const String productionEnvironment = 'PROD';
}

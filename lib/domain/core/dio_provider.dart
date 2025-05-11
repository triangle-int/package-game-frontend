import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/data/interceptors/auth_interceptor.dart';
import 'package:package_flutter/data/interceptors/version_interceptor.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final serverUrl = Env.getServerUrl();

  final options = BaseOptions(
    baseUrl: serverUrl,
    contentType: Headers.jsonContentType,
  );
  final dio = Dio(options);
  dio.interceptors.add(AuthInterceptor(ref.watch(authRepositoryProvider)));
  dio.interceptors.add(VersionInterceptor());
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();

      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        if (Env.getServerCertificate().isEmpty) {
          Logger().w('No server certificate provided');
          return true;
        }
        return cert.pem ==
            Env.getServerCertificate(); // Verify the certificate.
      };

      return client;
    },
  );
  return dio;
}

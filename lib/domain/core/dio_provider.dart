import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/data/interceptors/auth_interceptor.dart';
import 'package:package_flutter/data/interceptors/version_interceptor.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:package_flutter/domain/core/env_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final env = ref.watch(envProvider);
  final serverUrl = env.serverUrl;

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
        if (env.serverCertificate.isEmpty) {
          Logger().w('No server certificate provided');
          return true;
        }
        return cert.pem == env.serverCertificate; // Verify the certificate.
      };

      return client;
    },
  );
  return dio;
}

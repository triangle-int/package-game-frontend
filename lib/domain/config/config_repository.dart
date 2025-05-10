import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_repository.g.dart';

@riverpod
ConfigRepository configRepository(Ref ref) {
  return ConfigRepository(ref.watch(dioProvider));
}

class ConfigRepository {
  final Dio _dio;

  ConfigRepository(this._dio);

  Future<Config> getConfig() async {
    final response = await _dio.get('/config');

    final config = Config.fromJson(response.data as Map<String, dynamic>);
    return config;
  }
}

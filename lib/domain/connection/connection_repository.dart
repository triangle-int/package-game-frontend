import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_repository.g.dart';

@riverpod
ConnectionRepository connectionRepository(Ref ref) {
  return ConnectionRepository(ref.watch(dioProvider));
}

class ConnectionRepository {
  ConnectionRepository(this._dio);

  final Dio _dio;

  Future<Either<ServerFailure, Unit>> testConnection() async {
    try {
      await _dio.get('/ping');
      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}

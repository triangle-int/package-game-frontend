import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'satellite_repository.g.dart';

@riverpod
SatelliteRepository satelliteRepository(SatelliteRepositoryRef ref) {
  return SatelliteRepository(ref.watch(dioProvider));
}

class SatelliteRepository {
  final Dio _dio;

  SatelliteRepository(this._dio);

  Future<Either<ServerFailure, SatelliteBuilding>> collectMoney(int id) async {
    try {
      final response = await _dio.post(
        '/satellite/collect-money',
        data: {
          'satelliteId': id,
        },
      );

      Logger().d(response.data);

      return right(
        SatelliteBuilding.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}

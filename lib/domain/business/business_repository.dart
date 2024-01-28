import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

final businessRepositoryProvider = Provider(
  (ref) => BusinessRepository(
    ref.watch(dioProvider),
    ref.watch(buildingRepositoryProvider),
  ),
);

class BusinessRepository {
  final Dio _dio;
  final BuildingRepository _buildingRepository;

  BusinessRepository(this._dio, this._buildingRepository);

  Future<Either<ServerFailure, BusinessBuilding>> upgradeBusiness({
    required int businessId,
  }) async {
    try {
      final response = await _dio.post(
        '/business/upgrade-business',
        data: {
          'businessId': businessId,
        },
      );

      final building =
          BusinessBuilding.fromJson(response.data as Map<String, dynamic>);
      _buildingRepository.updateBuilding(building);
      return right(building);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, BusinessBuilding>> collectMoney({
    required int businessId,
  }) async {
    try {
      final response = await _dio.post(
        '/business/collect-money',
        data: {
          'businessId': businessId,
        },
      );

      final building =
          BusinessBuilding.fromJson(response.data as Map<String, dynamic>);
      _buildingRepository.updateBuilding(building);
      return right(building);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}

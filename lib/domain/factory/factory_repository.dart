import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/factory/factory_resource_select_failure.dart';

final factoryRepositoryProvider = Provider(
  (ref) => FactoryRepository(
    ref.watch(dioProvider),
    ref.watch(buildingRepositoryProvider),
  ),
);

class FactoryRepository {
  final Dio _dio;
  final BuildingRepository _buildingRepository;

  FactoryRepository(this._dio, this._buildingRepository);

  Future<Either<FactoryResourceSelectFailure, FactoryBuilding>> selectResource(
    int id,
    String resource,
  ) async {
    try {
      final response = await _dio.post(
        '/factory/set-factory-resource',
        data: {
          'factoryId': id,
          'resource': resource,
        },
      );

      final factoryBuilding =
          FactoryBuilding.fromJson(response.data as Map<String, dynamic>);
      _buildingRepository.updateBuilding(factoryBuilding);
      return right(factoryBuilding);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final message = e.response!.data['message'];
        if (message == 'factoryNotFound') {
          return left(const FactoryResourceSelectFailure.factoryNotFound());
        }
      }
      if (e.response != null) {
        return left(
          FactoryResourceSelectFailure.serverFailure(
            e.response!.data['message'].toString(),
          ),
        );
      }
      return left(FactoryResourceSelectFailure.serverFailure(e.message!));
    } catch (e) {
      return left(FactoryResourceSelectFailure.unexpectedFailure(e.toString()));
    }
  }

  Future<Either<ServerFailure, FactoryBuilding>> upgradeFactory(int id) async {
    try {
      final response = await _dio.post(
        '/factory/upgrade-factory',
        data: {
          'factoryId': id.toString(),
        },
      );

      final factoryBuilding =
          FactoryBuilding.fromJson(response.data as Map<String, dynamic>);
      _buildingRepository.updateBuilding(factoryBuilding);
      return right(factoryBuilding);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, FactoryBuilding>> toggleFactory(
    int id, {
    required bool enabled,
  }) async {
    try {
      final response = await _dio.post(
        '/factory/toggle-factory',
        data: {
          'factoryId': id,
          'state': enabled,
        },
      );

      final factoryBuilding =
          FactoryBuilding.fromJson(response.data as Map<String, dynamic>);
      _buildingRepository.updateBuilding(factoryBuilding);
      return right(factoryBuilding);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, FactoryBuilding>> getFactory({
    required int factoryId,
  }) async {
    try {
      final response = await _dio.get(
        '/factory/get-factory',
        queryParameters: {
          'factoryId': factoryId,
        },
      );

      final factoryBuilding =
          FactoryBuilding.fromJson(response.data as Map<String, dynamic>);
      _buildingRepository.updateBuilding(factoryBuilding);
      return right(factoryBuilding);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}

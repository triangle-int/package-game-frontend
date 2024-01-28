import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/get_business_response.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

final buildingRepositoryProvider =
    Provider((ref) => BuildingRepository(ref.watch(dioProvider)));

class BuildingRepository {
  final Dio _dio;

  BuildingRepository(this._dio);

  final _streamController =
      StreamController<Either<ServerFailure, List<Building>>>.broadcast();
  List<Building> _buildings = [];

  Stream<Either<ServerFailure, List<Building>>> getBuildingsInBound({
    required LatLng minCoords,
    required LatLng maxCoords,
  }) async* {
    try {
      final response = await _dio.get(
        '/building/get',
        queryParameters: {
          'minCoords': '${minCoords.latitude},${minCoords.longitude}',
          'maxCoords': '${maxCoords.latitude},${maxCoords.longitude}',
        },
      );
      final newBuildings = (response.data['buildings'] as List)
          .map((json) => Building.fromJson(json as Map<String, dynamic>))
          .toList();
      // newBuildings.sort((a, b) => a.id.compareTo(b.id));
      _buildings = newBuildings;
      yield right(_buildings);
    } on DioError catch (e) {
      yield left(ServerFailure.fromError(e));
    } finally {
      yield* _streamController.stream;
    }
  }

  Future<Either<ServerFailure, Unit>> createStorage(LatLng location) async {
    try {
      final response = await _dio.post(
        '/building/create-storage',
        data: {
          'location': '${location.latitude},${location.longitude}',
        },
      );

      final building = Building.fromJson(response.data as Map<String, dynamic>);
      updateBuilding(building);
      return right(unit);
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> createSatellite(
    LatLng location,
    int level,
  ) async {
    try {
      final response = await _dio.post(
        '/building/create-satellite',
        data: {
          'location': '${location.latitude},${location.longitude}',
          'level': level,
        },
      );

      final building = Building.fromJson(response.data as Map<String, dynamic>);
      updateBuilding(building);
      return right(unit);
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> createBusiness(LatLng location) async {
    try {
      final response = await _dio.post(
        '/building/create-business',
        data: {
          'location': '${location.latitude},${location.longitude}',
        },
      );

      final building = Building.fromJson(response.data as Map<String, dynamic>);
      updateBuilding(building);
      return right(unit);
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> createFactory(LatLng location) async {
    try {
      final response = await _dio.post(
        '/building/create-factory',
        data: {
          'location': '${location.latitude},${location.longitude}',
        },
      );
      Logger().d(response.data);
      final building = Building.fromJson(response.data as Map<String, dynamic>);
      updateBuilding(building);
      return right(unit);
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> destroyBuilding(int buildingId) async {
    try {
      final response = await _dio.post(
        '/building/remove-building',
        data: {
          'buildingId': buildingId,
        },
      );
      Logger().d(response.data);
      _buildings.removeWhere((b) => b.id == buildingId);
      _streamController.add(right(_buildings));

      return right(unit);
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, MarketBuilding>> getMarket({
    required int marketId,
  }) async {
    try {
      final response = await _dio.get(
        '/market/get-market',
        queryParameters: {
          'marketId': marketId,
        },
      );

      Logger().d('getMarket: ${response.data}');
      return right(
        MarketBuilding.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, StorageBuilding>> getStorage({
    required int storageId,
  }) async {
    try {
      final response = await _dio.get(
        '/building/get-storage',
        queryParameters: {
          'buildingId': storageId,
        },
      );

      Logger().d('getStorage: ${response.data}');
      return right(
        StorageBuilding.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, GetBusinessResponse>> getBusiness({
    required int businessId,
  }) async {
    try {
      final response = await _dio.get(
        '/business/get-business',
        queryParameters: {
          'businessId': businessId,
        },
      );
      Logger().d(response.data);

      return right(
        GetBusinessResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioError catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  void updateBuilding(Building building) {
    Logger().d('Updating building...');
    _buildings.removeWhere((b) => b.id == building.id);
    _buildings.add(building);
    _streamController.add(right(_buildings));
  }
}

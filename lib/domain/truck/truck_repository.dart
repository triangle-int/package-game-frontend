import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:package_flutter/domain/truck/calculated_path.dart';
import 'package:package_flutter/domain/truck/delivery_buildings.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_schedules_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'truck_repository.g.dart';

@riverpod
TruckRepository truckRepository(Ref ref) {
  return TruckRepository(
    ref.watch(dioProvider),
    ref.watch(socketRepositoryProvider),
  );
}

class TruckRepository {
  final Dio _dio;
  final SocketRepository _socketRepository;

  StreamSubscription<Map<String, dynamic>>? _truckCreatedSubscription;
  StreamSubscription<Map<String, dynamic>>? _truckArrivedSubscription;

  TruckRepository(this._dio, this._socketRepository);

  final _streamController =
      StreamController<Either<ServerFailure, List<Truck>>>.broadcast();
  final List<Truck> trucks = [];

  Future<Either<ServerFailure, CalculatedPath>> calculatePathCost(
    int aId,
    int bId, {
    required int truckType,
    required int resourceCount,
  }) async {
    try {
      final response = await _dio.post(
        '/truck/calculate-path-cost',
        data: {
          'aId': aId,
          'bId': bId,
          'truckType': truckType,
          'resourceCount': resourceCount,
        },
      );

      return right(
        CalculatedPath.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> createTruck(
    int aId,
    int bId, {
    required int truckType,
    required int resourceCount,
    required int scheduleDuration,
    required String resourceName,
  }) async {
    try {
      bool createSchedule = true;
      int interval = scheduleDuration;
      if (scheduleDuration == 0) {
        createSchedule = false;
      } else {
        interval--;
      }

      await _dio.post(
        '/truck/create-truck',
        data: {
          'aId': aId,
          'bId': bId,
          'truckType': truckType,
          'interval': interval,
          'createSchedule': createSchedule,
          'resourceCount': resourceCount,
          'resourceName': resourceName,
        },
      );

      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, TruckSchedulesResponse>> getSchedules() async {
    try {
      final response = await _dio.get('/truck/get-schedules');

      return right(
        TruckSchedulesResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  void removeTruck(int truckId) {
    trucks.removeWhere((t) => t.id == truckId);
    _streamController.add(right(trucks));
  }

  Stream<Either<ServerFailure, List<Truck>>> getTrucks() async* {
    try {
      final response = await _dio.get('/truck/get-trucks');

      final trucksLocal = (response.data as List<dynamic>)
          .map((t) => Truck.fromJson(t as Map<String, dynamic>))
          .toList();

      Logger().d('Trucks: $trucksLocal');
      trucks.clear();
      trucks.addAll(trucksLocal);

      // Listen for new trucks being created
      _truckCreatedSubscription?.cancel();
      _truckCreatedSubscription =
          _socketRepository.getTruckCreatedUpdates().listen((data) {
        Logger().d('Truck created via WebSocket!');
        final truck = Truck.fromJson(data);
        trucks.add(truck);
        _streamController.add(right(trucks));
      });

      // Listen for trucks arriving (and remove them from the list)
      _truckArrivedSubscription?.cancel();
      _truckArrivedSubscription =
          _socketRepository.getTruckArrivedUpdates().listen((data) {
        Logger().d('Truck arrived via WebSocket!');
        final truckId = data['id'] as int;
        trucks.removeWhere((t) => t.id == truckId);
        _streamController.add(right(trucks));
      });

      yield right(trucks);
      yield* _streamController.stream;
    } on DioException catch (e) {
      yield left(ServerFailure.fromError(e));
    } catch (e) {
      Logger().e("Can't load trucks",
          error: e, stackTrace: (e as Error).stackTrace);
      rethrow;
    }
  }

  Future<Either<ServerFailure, DeliveryBuildings>> getDeliveryTargets() async {
    try {
      final response = await _dio.get('/truck/get-delivery-targets');

      return right(
        DeliveryBuildings.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> removeSchedule(int scheduleId) async {
    try {
      await _dio.post(
        '/truck/remove-truck-schedule',
        data: {
          'scheduleId': scheduleId,
        },
      );

      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}

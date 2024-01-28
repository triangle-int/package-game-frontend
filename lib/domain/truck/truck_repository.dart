import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/firebase_messaging_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/truck/calculated_path.dart';
import 'package:package_flutter/domain/truck/delivery_buildings.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_schedules_response.dart';

final truckRepositoryProvider = Provider(
  (ref) => TruckRepository(
    ref.watch(dioProvider),
    ref.watch(firebaseMessagingProvider),
  ),
);

class TruckRepository {
  final Dio _dio;
  final FirebaseMessaging _messaging;

  StreamSubscription<RemoteMessage>? _subscription;

  TruckRepository(this._dio, this._messaging);

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
      trucks.addAll(trucksLocal);

      if (_subscription == null) {
        await _messaging.subscribeToTopic('trucks');
      }

      _subscription?.cancel();
      _subscription = FirebaseMessaging.onMessage
          .where((message) => message.data.containsKey('truck'))
          .listen((data) {
        Logger().d('Truck received!');
        final d = data.data['truck'] as String;
        final json = jsonDecode(d) as Map<String, dynamic>;
        final truck = Truck.fromJson(json);
        trucks.add(truck);
        _streamController.add(right(trucks));
      });
      yield right(trucks);
      yield* _streamController.stream;
    } on DioException catch (e) {
      yield left(ServerFailure.fromError(e));
    } catch (e) {
      Logger().e("Can't load trucks", e, (e as Error).stackTrace);
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

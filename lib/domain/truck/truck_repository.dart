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
  final repository = TruckRepository(
    ref.watch(dioProvider),
    ref.watch(socketRepositoryProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
}

class TruckRepository {
  final Dio _dio;
  final SocketRepository _socketRepository;

  TruckRepository(this._dio, this._socketRepository);

  StreamController<Either<ServerFailure, List<Truck>>>? _streamController;
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
    _emitTrucks();
  }

  void _emitTrucks() {
    final controller = _streamController;
    if (controller != null && !controller.isClosed) {
      // Each state must own its list: mutating an earlier state prevents Bloc
      // from detecting changes and can leave old markers on the map.
      controller.add(right(List<Truck>.unmodifiable(trucks)));
    }
  }

  Stream<Either<ServerFailure, List<Truck>>> getTrucks() {
    late StreamController<Either<ServerFailure, List<Truck>>> controller;
    StreamSubscription<Map<String, dynamic>>? createdSubscription;
    StreamSubscription<Map<String, dynamic>>? arrivedSubscription;
    StreamSubscription<void>? connectionSubscription;
    final pendingUpdates = <void Function()>[];
    var loading = false;
    var refreshRequested = false;
    var cancelled = false;

    void update(void Function() apply) {
      if (loading) {
        pendingUpdates.add(apply);
      } else {
        apply();
        _emitTrucks();
      }
    }

    Future<void> refresh() async {
      if (loading) {
        refreshRequested = true;
        return;
      }

      do {
        refreshRequested = false;
        loading = true;
        try {
          final response = await _dio.get('/truck/get-trucks');
          final loaded = (response.data as List<dynamic>)
              .map((t) => Truck.fromJson(t as Map<String, dynamic>))
              .toList();
          if (cancelled) return;
          // A reconnect snapshot can be older than a truckCreated event that
          // was just received (the create transaction and the read may race).
          // Keep still-active local trucks so the stale snapshot cannot make
          // a courier disappear from the map.
          final loadedIds = loaded.map((truck) => truck.id).toSet();
          final now = DateTime.now();
          final activeLocal = trucks
              .where(
                (truck) =>
                    !loadedIds.contains(truck.id) && truck.endTime.isAfter(now),
              )
              .toList();
          trucks
            ..clear()
            ..addAll(loaded)
            ..addAll(activeLocal);
          for (final apply in pendingUpdates) {
            apply();
          }
          pendingUpdates.clear();
          loading = false;
          _emitTrucks();
        } on DioException catch (e) {
          if (cancelled) return;
          for (final apply in pendingUpdates) {
            apply();
          }
          pendingUpdates.clear();
          loading = false;
          controller.add(left(ServerFailure.fromError(e)));
        } catch (e, stackTrace) {
          Logger().e("Can't load trucks", error: e, stackTrace: stackTrace);
          if (cancelled) return;
          for (final apply in pendingUpdates) {
            apply();
          }
          pendingUpdates.clear();
          loading = false;
          controller.add(left(ServerFailure.unknown(e.toString())));
        }
      } while (refreshRequested && !cancelled);
    }

    controller = StreamController(
      onListen: () {
        _streamController = controller;
        // Subscribe before fetching so creations and arrivals during the HTTP
        // request are applied to the snapshot instead of being lost.
        createdSubscription =
            _socketRepository.getTruckCreatedUpdates().listen((data) {
          final truck = Truck.fromJson(data);
          update(() {
            trucks.removeWhere((existing) => existing.id == truck.id);
            trucks.add(truck);
          });
        });
        arrivedSubscription =
            _socketRepository.getTruckArrivedUpdates().listen((data) {
          final truckId = data['id'] as int;
          update(() => trucks.removeWhere((truck) => truck.id == truckId));
        });
        // A connection can be established after the first snapshot, or
        // restored after missing events. Reconcile on every server handshake.
        connectionSubscription =
            _socketRepository.getConnectionUpdates().listen((_) => refresh());
        refresh();
      },
      onCancel: () async {
        cancelled = true;
        if (identical(_streamController, controller)) {
          _streamController = null;
        }
        await createdSubscription?.cancel();
        await arrivedSubscription?.cancel();
        await connectionSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  void dispose() {
    _streamController?.close();
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

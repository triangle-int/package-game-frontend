import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_flutter/bloc/building/building_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/domain/truck/calculated_path.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/domain/truck/truck_schedules_response.dart';

class _Buildings implements BuildingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factories implements FactoryRepository {
  final request = Completer<Either<ServerFailure, FactoryBuilding>>();

  @override
  Future<Either<ServerFailure, FactoryBuilding>> getFactory(
          {required int factoryId}) =>
      request.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trucks implements TruckRepository {
  final path = Completer<Either<ServerFailure, CalculatedPath>>();
  final creation = Completer<Either<ServerFailure, Unit>>();
  final schedules = Completer<Either<ServerFailure, TruckSchedulesResponse>>();
  int creationCount = 0;

  @override
  Future<Either<ServerFailure, CalculatedPath>> calculatePathCost(
    int aId,
    int bId, {
    required int truckType,
    required int resourceCount,
  }) =>
      path.future;

  @override
  Future<Either<ServerFailure, Unit>> createTruck(
    int aId,
    int bId, {
    required int truckType,
    required int resourceCount,
    required int scheduleDuration,
    required String resourceName,
  }) {
    creationCount++;
    return creation.future;
  }

  @override
  Future<Either<ServerFailure, TruckSchedulesResponse>> getSchedules() =>
      schedules.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _start = Building.storage(
  id: 1,
  level: 1,
  geohex: 'a',
  geohash: null,
  ownerId: 1,
);
const _destination = Building.storage(
  id: 2,
  level: 1,
  geohex: 'b',
  geohash: null,
  ownerId: 1,
);

Future<void> _flushEvents() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

Future<void> _configureRoute(DoggieExpressBloc bloc) async {
  bloc
    ..add(const DoggieExpressEvent.pointASelected(_start))
    ..add(const DoggieExpressEvent.pointBSelected(_destination))
    ..add(const DoggieExpressEvent.resourceSelected('wood'))
    ..add(DoggieExpressEvent.amountEntered(BigInt.from(10)))
    ..add(const DoggieExpressEvent.truckTypeUpdated(0))
    ..add(const DoggieExpressEvent.scheduleDurationUpdated(0));
  await _flushEvents();
}

CalculatedPath _path() => CalculatedPath(
      costPerTruck: 1,
      cost: BigInt.one,
      distance: 1,
    );

void main() {
  test('a non-JSON server error is reported without crashing', () {
    final request = RequestOptions(path: '/truck/get-schedules');
    final error = DioException(
      requestOptions: request,
      response: Response<String>(
        requestOptions: request,
        statusCode: 500,
        data: 'Server error',
      ),
    );
    expect(ServerFailure.fromError(error),
        const ServerFailure.unknown('Server error'));
  });

  test('updating a building replaces the previous map entry', () async {
    final bloc = BuildingBloc(_Buildings());
    bloc.add(const BuildingEvent.buildingUpdated(_start));
    await _flushEvents();
    bloc.add(BuildingEvent.buildingUpdated(_start.copyWith(level: 2)));
    await _flushEvents();
    expect(bloc.state.buildings, hasLength(1));
    expect(bloc.state.buildings.single.level, 2);
    await bloc.close();
  });

  test('a late factory refresh cannot undo a newer factory update', () async {
    final repository = _Factories();
    final bloc = FactoryBloc(repository);
    const factory = FactoryBuilding(
      id: 1,
      geohex: 'a',
      geohash: null,
      currentResource: 'wheel',
      resourceToUpgrade1: null,
      resourceToUpgrade2: null,
      resourceToUpgrade3: null,
      level: 1,
      ownerId: 1,
      enabled: true,
    );
    bloc.add(const FactoryEvent.factoryRequested(1));
    await _flushEvents();
    bloc.add(FactoryEvent.factoryGot(factory.copyWith(enabled: false)));
    await _flushEvents();
    repository.request.complete(right(factory));
    await _flushEvents();
    expect((bloc.state as FactoryStateLoadSuccess).factoryBuilding.enabled,
        isFalse);
    await bloc.close();
  });

  test('an old route calculation cannot confirm a changed amount', () async {
    final trucks = _Trucks();
    final bloc = DoggieExpressBloc(trucks);
    await _configureRoute(bloc);
    bloc.add(const DoggieExpressEvent.calculate());
    await _flushEvents();
    bloc.add(DoggieExpressEvent.amountEntered(BigInt.from(20)));
    await _flushEvents();
    trucks.path.complete(right(_path()));
    await _flushEvents();
    expect(bloc.state.amount, BigInt.from(20));
    expect(bloc.state.path, isNull);
    expect(bloc.state.isLoading, isFalse);
    await bloc.close();
  });

  test('repeated confirmation sends only one delivery request', () async {
    final trucks = _Trucks();
    final bloc = DoggieExpressBloc(trucks);
    await _configureRoute(bloc);
    bloc.add(const DoggieExpressEvent.calculate());
    await _flushEvents();
    trucks.path.complete(right(_path()));
    await _flushEvents();
    bloc
      ..add(const DoggieExpressEvent.confirm())
      ..add(const DoggieExpressEvent.confirm());
    await _flushEvents();
    expect(trucks.creationCount, 1);
    trucks.creation.complete(right(unit));
    await _flushEvents();
    expect(bloc.state.success, isTrue);
    await bloc.close();
  });

  test('a late routes response does not reopen the closed routes screen',
      () async {
    final trucks = _Trucks();
    final bloc = SidebarBloc(trucks);
    bloc.add(const SidebarEvent.routesSelected());
    await _flushEvents();
    bloc.add(const SidebarEvent.initialPageSelected());
    await _flushEvents();
    trucks.schedules.complete(right(const TruckSchedulesResponse(
      schedules: [],
      trucks: [],
    )));
    await _flushEvents();
    expect(bloc.state, isA<SidebarStateInitial>());
    await bloc.close();
  });
}

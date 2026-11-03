import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';

class FakeSocketRepository extends Fake implements SocketRepository {
  final created = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  final arrived = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  final connected = StreamController<void>.broadcast(sync: true);

  @override
  Stream<Map<String, dynamic>> getTruckCreatedUpdates() => created.stream;

  @override
  Stream<Map<String, dynamic>> getTruckArrivedUpdates() => arrived.stream;

  @override
  Stream<void> getConnectionUpdates() => connected.stream;

  Future<void> close() async {
    await created.close();
    await arrived.close();
    await connected.close();
  }
}

/// Holds each snapshot request so socket events can be delivered during it.
class ControlledSnapshots {
  ControlledSnapshots(int count)
      : started = List.generate(count, (_) => Completer<void>()),
        responses = List.generate(
          count,
          (_) => Completer<List<Map<String, dynamic>>>(),
        ) {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final index = requestCount++;
      if (index >= responses.length) {
        handler.reject(DioException(
          requestOptions: options,
          error: 'Unexpected extra snapshot request',
        ));
        return;
      }
      started[index].complete();
      final data = await responses[index].future;
      handler.resolve(Response(requestOptions: options, data: data));
    }));
  }

  final dio = Dio();
  final List<Completer<void>> started;
  final List<Completer<List<Map<String, dynamic>>>> responses;
  int requestCount = 0;
}

class ObservedTrucks {
  final snapshots = <List<int>>[];
  final added = StreamController<int>.broadcast(sync: true);

  void record(List<Truck> trucks) {
    snapshots.add(trucks.map((truck) => truck.id).toList());
    added.add(snapshots.length);
  }

  Future<void> waitFor(int count) async {
    if (snapshots.length < count) {
      await added.stream.firstWhere((n) => n >= count).timeout(
            const Duration(seconds: 10),
          );
    }
  }
}

Map<String, dynamic> truckJson(int id) => {
      'id': id,
      'startTime': '2026-01-01T00:00:00.000Z',
      'endTime': '2026-01-01T01:00:00.000Z',
      'path': '',
      'truckType': 0,
      'destinationId': 2,
      'startId': 1,
      'resource': 'wood',
      'resourceCount': '1',
      'scheduleId': null,
      'ownerId': 1,
    };

void main() {
  test('parses a truck after its starting building has been removed', () {
    final truck = Truck.fromJson({...truckJson(1), 'startId': null});
    expect(truck.startId, isNull);
    expect(truck.copyWith(startId: 1).copyWith(startId: null).startId, isNull);
  });

  test('replays updates during loading and emits immutable snapshots',
      () async {
    final socket = FakeSocketRepository();
    final request = Completer<void>();
    final dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      await request.future;
      handler.resolve(Response(requestOptions: options, data: [truckJson(1)]));
    }));
    final repository = TruckRepository(dio, socket);
    final snapshots = <List<Truck>>[];
    final firstSnapshot = Completer<void>();
    final createdSnapshots = Completer<void>();
    final removedSnapshot = Completer<void>();
    final subscription = repository.getTrucks().listen((result) {
      result.fold((failure) => fail('Unexpected failure: $failure'), (trucks) {
        snapshots.add(trucks);
        if (snapshots.length == 1) firstSnapshot.complete();
        if (snapshots.length == 3) createdSnapshots.complete();
        if (snapshots.length == 4) removedSnapshot.complete();
      });
    });

    socket.created.add(truckJson(2));
    socket.arrived.add({'id': 1});
    request.complete();
    await firstSnapshot.future.timeout(const Duration(seconds: 10));
    expect(snapshots.single.map((truck) => truck.id), [2]);

    socket.created.add(truckJson(2));
    socket.created.add(truckJson(3));
    await createdSnapshots.future.timeout(const Duration(seconds: 10));
    expect(snapshots.last.map((truck) => truck.id), [2, 3]);
    expect(snapshots.first.map((truck) => truck.id), [2]);

    repository.removeTruck(2);
    await removedSnapshot.future.timeout(const Duration(seconds: 10));
    expect(snapshots.last.map((truck) => truck.id), [3]);
    expect(snapshots[snapshots.length - 2].map((truck) => truck.id), [2, 3]);

    await subscription.cancel();
    repository.dispose();
    await socket.close();
    dio.close();
  });

  test('handshake reconciles missed trucks and replays events during refresh',
      () async {
    final socket = FakeSocketRepository();
    final requests = ControlledSnapshots(2);
    final repository = TruckRepository(requests.dio, socket);
    final observed = ObservedTrucks();
    final subscription = repository.getTrucks().listen((result) {
      result.fold(
          (failure) => fail('Unexpected failure: $failure'), observed.record);
    });

    await requests.started[0].future.timeout(const Duration(seconds: 10));
    requests.responses[0].complete([truckJson(1)]);
    await observed.waitFor(1);
    expect(observed.snapshots.last, [1]);

    // A new connection must reconcile changes missed while disconnected.
    socket.connected.add(null);
    await requests.started[1].future.timeout(const Duration(seconds: 10));
    socket.arrived.add({'id': 1});
    socket.created.add(truckJson(2));
    requests.responses[1].complete([truckJson(1), truckJson(3)]);
    await observed.waitFor(2);
    expect(observed.snapshots.last, [3, 2]);
    expect(requests.requestCount, 2);

    await subscription.cancel();
    repository.dispose();
    await socket.close();
    await observed.added.close();
    requests.dio.close();
  });

  test('handshakes during a request queue one follow-up snapshot', () async {
    final socket = FakeSocketRepository();
    final requests = ControlledSnapshots(2);
    final repository = TruckRepository(requests.dio, socket);
    final observed = ObservedTrucks();
    final subscription = repository.getTrucks().listen((result) {
      result.fold(
          (failure) => fail('Unexpected failure: $failure'), observed.record);
    });

    await requests.started[0].future.timeout(const Duration(seconds: 10));
    socket.connected.add(null);
    socket.connected.add(null);
    socket.created.add(truckJson(2));
    socket.arrived.add({'id': 1});
    requests.responses[0].complete([truckJson(1)]);
    await requests.started[1].future.timeout(const Duration(seconds: 10));
    await observed.waitFor(1);
    expect(observed.snapshots.first, [2]);

    socket.arrived.add({'id': 2});
    socket.created.add(truckJson(5));
    requests.responses[1].complete([truckJson(2), truckJson(4)]);
    await observed.waitFor(2);
    expect(observed.snapshots.last, [4, 5]);
    expect(requests.requestCount, 2);

    await subscription.cancel();
    repository.dispose();
    await socket.close();
    await observed.added.close();
    requests.dio.close();
  });
}

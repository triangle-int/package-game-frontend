import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/domain/tutorial/tutorial_repository.dart';
import 'package:package_flutter/presentation/map/truck_markers.dart';

class FakeTruckRepository extends Fake implements TruckRepository {
  final removed = <int>[];

  @override
  void removeTruck(int id) => removed.add(id);
}

class FakeTutorialRepository extends Fake implements TutorialRepository {}

class RecordingTutorialBloc extends TutorialBloc {
  RecordingTutorialBloc() : super(FakeTutorialRepository());

  int arrivals = 0;

  @override
  void add(TutorialEvent event) {
    if (event is TutorialEventTruckArrived) arrivals++;
    super.add(event);
  }
}

void main() {
  testWidgets('shows and animates both players deliveries on the main map',
      (tester) async {
    final repository = FakeTruckRepository();
    final truckBloc = TruckBloc(repository);
    final tutorialBloc = RecordingTutorialBloc();
    var now = DateTime.utc(2026, 1, 1);
    final path = encodePolyline([
      [55.0, 37.0],
      [55.001, 37.001],
    ], accuracyExponent: 6);
    Truck truck(int id, int ownerId, int durationMinutes) => Truck(
          id: id,
          ownerId: ownerId,
          startTime: now,
          endTime: now.add(Duration(minutes: durationMinutes)),
          path: path,
          truckType: (id - 1) % 3,
          destinationId: 1,
          destinationBuilding: null,
          startId: 1,
          startBuilding: null,
          resource: 'wood',
          resourceCount: BigInt.one,
          scheduleId: null,
        );

    truckBloc.add(TruckEvent.trucksReceived(
      dartz.right([truck(1, 10, 10), truck(2, 20, 20)]),
    ));
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TruckBloc>(create: (_) => truckBloc),
          BlocProvider<TutorialBloc>(create: (_) => tutorialBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FlutterMap(
              options: const MapOptions(initialCenter: LatLng(55, 37)),
              children: [TruckMarkers(ownerId: 10, clock: () => now)],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    List<Marker> markers() =>
        tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers;
    expect(markers(), hasLength(2));
    expect(markers().map((marker) => marker.point.latitude), [55, 55]);

    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 100));
    expect(markers(), hasLength(2));
    expect(markers()[0].point.latitude, closeTo(55.0005, 0.000001));
    expect(markers()[1].point.latitude, closeTo(55.00025, 0.000001));

    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(markers(), hasLength(1));
    expect(markers().single.point.latitude, closeTo(55.0005, 0.000001));
    expect(repository.removed, [1]);
    expect(tutorialBloc.arrivals, 1);

    // The later removal update must not notify the tutorial a second time.
    final otherTruck = truckBloc.state is TruckStateLoadSuccess
        ? (truckBloc.state as TruckStateLoadSuccess).trucks.last
        : throw StateError('Expected deliveries');
    truckBloc.add(TruckEvent.trucksReceived(dartz.right([otherTruck])));
    await tester.pump();
    expect(tutorialBloc.arrivals, 1);

    // An early removal is not an arrival (for example, a cancelled delivery).
    final ownedTruck = truck(3, 10, 10);
    truckBloc
        .add(TruckEvent.trucksReceived(dartz.right([otherTruck, ownedTruck])));
    await tester.pump();
    truckBloc.add(TruckEvent.trucksReceived(dartz.right([otherTruck])));
    await tester.pump();
    expect(tutorialBloc.arrivals, 1);

    // A socket update can arrive shortly before the local timer expires.
    final arrivingTruck = truck(4, 10, 10);
    truckBloc.add(
        TruckEvent.trucksReceived(dartz.right([otherTruck, arrivingTruck])));
    await tester.pump();
    now = now.add(const Duration(minutes: 9, seconds: 57));
    truckBloc.add(TruckEvent.trucksReceived(dartz.right([otherTruck])));
    await tester.pump();
    expect(tutorialBloc.arrivals, 2);

    await tester.pumpWidget(const SizedBox());
  });
}

import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geohex/geohex.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/satellite/lines_and_hexes.dart';
import 'package:package_flutter/domain/satellite/satellite_line.dart';
import 'package:package_flutter/domain/satellite/satellite_repository.dart';

part 'satellite_event.dart';
part 'satellite_state.dart';
part 'satellite_bloc.freezed.dart';

class SatelliteBloc extends Bloc<SatelliteEvent, SatelliteState> {
  final SatelliteRepository _repository;

  SatelliteBloc(this._repository) : super(const SatelliteState.initial()) {
    on<SatelliteEvent>((event, emit) async {
      switch (event) {
        case CollectedMoney(:final id):
          Logger().d(
            'Collecting from businesses by satellite',
          );
          emit(const SatelliteState.loading());
          final failureOrSatellite = await _repository.collectMoney(id);

          failureOrSatellite.fold(
            (failure) {},
            (satellite) {
              Logger().d(satellite);
              final lines = <SatelliteLine>[];
              final firstLayer = <Zone>[];
              final secondLayer = <Zone>[];
              final q = Queue<SatelliteBuilding>();
              q.add(satellite);
              while (q.isNotEmpty) {
                final current = q.removeFirst();

                if (current.level == 1) {
                  final hex = Zone.byCode(current.geohex);

                  firstLayer.addAll(hex.neighbours!);
                  for (final neighbor in hex.neighbours!) {
                    for (final n in neighbor.neighbours!) {
                      if (firstLayer.any((h) => h.code == n.code) ||
                          secondLayer.any((h) => h.code == n.code)) continue;

                      secondLayer.add(n);
                    }
                  }

                  secondLayer.removeWhere((e) => e.code == hex.code);
                }

                for (final s in current.children ?? <SatelliteBuilding>[]) {
                  final start = Zone.byCode(current.geohex);
                  final end = Zone.byCode(s.geohex);

                  if (satellite.id == current.id) {
                    Logger().d(
                      'Satellite ${satellite.id} is collecting from ${s.id}',
                    );
                  }

                  q.addLast(s);
                  lines.add(
                    SatelliteLine(
                      fromId: current.id,
                      toId: s.id,
                      showHexes: s.level == 1,
                      start: LatLng(start.lat, start.lon),
                      end: LatLng(end.lat, end.lon),
                    ),
                  );
                }
              }

              emit(
                SatelliteState.showLines(
                  LinesAndHexes(
                    firstLayer: firstLayer,
                    secondLayer: secondLayer,
                    lines: lines,
                  ),
                ),
              );
            },
          );

          Logger().d(
            'Collected!',
          );
      }
    });
  }
}

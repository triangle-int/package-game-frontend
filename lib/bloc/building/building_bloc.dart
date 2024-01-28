import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:rxdart/rxdart.dart';

part 'building_event.dart';
part 'building_state.dart';
part 'building_bloc.freezed.dart';

class BuildingBloc extends Bloc<BuildingEvent, BuildingState> {
  final BuildingRepository _repository;

  StreamSubscription? _streamSubscription;

  BuildingBloc(this._repository) : super(BuildingState.initial()) {
    on<BuildingEvent>(
      (event, emit) async {
        await event.map(
          updatedBounds: (e) async {
            emit(
              state.copyWith(
                isLoading: true,
                failureOrNull: null,
              ),
            );
            Logger().d(
              'Bounds updated: ${e.bounds.southWest} - ${e.bounds.northEast}',
            );
            _streamSubscription?.cancel();
            _streamSubscription = _repository
                .getBuildingsInBound(
                  minCoords: e.bounds.southWest!,
                  maxCoords: e.bounds.northEast!,
                )
                .listen((b) => add(BuildingEvent.buildingsReceived(b)));
          },
          buildingsReceived: (e) {
            Logger().d('Buildings received!');
            emit(
              e.buildingsOrFailure.fold(
                (f) => state.copyWith(
                  isLoading: false,
                  failureOrNull: f,
                ),
                (b) => state.copyWith(
                  isLoading: false,
                  failureOrNull: null,
                  buildings: b,
                ),
              ),
            );
          },
          buildingUpdated: (e) {
            final list = List<Building>.from(state.buildings);
            list.removeWhere((b) => b.id == e.building.id);
            emit(state.copyWith(buildings: [...state.buildings, e.building]));
          },
        );
      },
      transformer: (events, mapper) {
        final debounce = events
            .where(
              (event) => event.map(
                updatedBounds: (e) => true,
                buildingsReceived: (e) => false,
                buildingUpdated: (e) => false,
              ),
            )
            .debounceTime(const Duration(milliseconds: 200));
        final nonDebounce = events.where(
          (event) => event.map(
            updatedBounds: (e) => false,
            buildingsReceived: (e) => true,
            buildingUpdated: (e) => true,
          ),
        );
        return MergeStream([debounce, nonDebounce]).asyncExpand(mapper);
      },
    );
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}

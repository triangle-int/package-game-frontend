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
        switch (event) {
          case UpdatedBounds(:final bounds):
            emit(
              state.copyWith(
                isLoading: true,
                failureOrNull: null,
              ),
            );
            Logger().d(
              'Bounds updated: ${bounds.southWest} - ${bounds.northEast}',
            );
            _streamSubscription?.cancel();
            _streamSubscription = _repository
                .getBuildingsInBound(
                  minCoords: bounds.southWest,
                  maxCoords: bounds.northEast,
                )
                .listen((b) => add(BuildingEvent.buildingsReceived(b)));
          case BuildingsReceived(:final buildingsOrFailure):
            Logger().d('Buildings received!');
            emit(
              buildingsOrFailure.fold(
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
          case BuildingUpdated(:final building):
            final list = List<Building>.from(state.buildings);
            list.removeWhere((b) => b.id == building.id);
            emit(state.copyWith(buildings: [...state.buildings, building]));
        }
      },
      transformer: (events, mapper) {
        final debounce = events
            .where(
              (event) => switch (event) {
                UpdatedBounds() => true,
                BuildingsReceived() => false,
                BuildingUpdated() => false,
              },
            )
            .debounceTime(const Duration(milliseconds: 200));
        final nonDebounce = events.where(
          (event) => switch (event) {
            UpdatedBounds() => false,
            BuildingsReceived() => true,
            BuildingUpdated() => true,
          },
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

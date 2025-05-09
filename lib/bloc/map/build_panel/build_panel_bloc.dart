import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'build_panel_event.dart';
part 'build_panel_state.dart';
part 'build_panel_bloc.freezed.dart';

class BuildPanelBloc extends Bloc<BuildPanelEvent, BuildPanelState> {
  final BuildingRepository _repository;

  BuildPanelBloc(this._repository) : super(const BuildPanelState.initial()) {
    on<BuildPanelEvent>((event, emit) async {
      switch (event) {
        case BuildPanelEventBuildBusiness(:final location):
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure = await _repository.createBusiness(location);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        case BuildPanelEventBuildFactory(:final location):
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure = await _repository.createFactory(location);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        case BuildPanelEventBuildStorage(:final location):
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure = await _repository.createStorage(location);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        case BuildPanelEventBuildSatellite(:final location, :final level):
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure =
              await _repository.createSatellite(location, level);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
      }
    });
  }
}

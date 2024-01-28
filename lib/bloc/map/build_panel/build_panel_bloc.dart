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
      await event.map(
        buildBusiness: (e) async {
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure = await _repository.createBusiness(e.location);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        },
        buildFactory: (e) async {
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure = await _repository.createFactory(e.location);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        },
        buildStorage: (e) async {
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure = await _repository.createStorage(e.location);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        },
        buildSatellite: (e) async {
          emit(const BuildPanelState.loadInProgress());

          final unitOrFailure =
              await _repository.createSatellite(e.location, e.level);

          unitOrFailure.fold(
            (failure) => emit(BuildPanelState.loadFailure(failure)),
            (unit) => emit(const BuildPanelState.loadSuccess()),
          );
        },
      );
    });
  }
}

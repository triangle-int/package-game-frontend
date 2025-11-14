import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building_repository.dart';

part 'build_mode_event.dart';
part 'build_mode_state.dart';
part 'build_mode_bloc.freezed.dart';

class BuildModeBloc extends Bloc<BuildModeEvent, BuildModeState> {
  final BuildingRepository _buildingRepository;

  BuildModeBloc(this._buildingRepository)
      : super(const BuildModeState.buildMode()) {
    on<BuildModeEvent>((event, emit) async {
      switch (event) {
        case BuildModeEventEnteredDestroyMode():
          emit(const BuildModeState.destroyMode());
        case BuildModeEventRemovedBuilding(:final id):
          // TODO(P5ina): Check usage of await here
          _buildingRepository.destroyBuilding(id);
        case BuildModeEventExitedDestroyMode():
          emit(const BuildModeState.buildMode());
      }
    });
  }
}

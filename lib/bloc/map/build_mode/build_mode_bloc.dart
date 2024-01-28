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
      await event.map(
        enteredDestroyMode: (_) async =>
            emit(const BuildModeState.destroyMode()),
        removedBuilding: (s) async {
          _buildingRepository.destroyBuilding(s.id);
        },
        exitedDestroyMode: (_) async => emit(const BuildModeState.buildMode()),
      );
    });
  }
}

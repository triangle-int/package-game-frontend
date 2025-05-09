import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';

part 'factory_toggle_event.dart';
part 'factory_toggle_state.dart';
part 'factory_toggle_bloc.freezed.dart';

class FactoryToggleBloc extends Bloc<FactoryToggleEvent, FactoryToggleState> {
  final FactoryRepository _factoryRepository;

  FactoryToggleBloc(this._factoryRepository)
      : super(const FactoryToggleState.initial()) {
    on<FactoryToggleEvent>((event, emit) async {
      switch (event) {
        case FactoryToggleEventToggled(:final building):
          emit(const FactoryToggleState.loadInProgress());
          final buildingOrFailure = await _factoryRepository.toggleFactory(
            building.id,
            enabled: !building.enabled,
          );

          buildingOrFailure.fold(
            (f) => emit(FactoryToggleState.loadFailure(f)),
            (building) => emit(FactoryToggleState.loadSuccess(building)),
          );
      }
    });
  }
}

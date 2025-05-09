import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';

part 'factory_event.dart';
part 'factory_state.dart';
part 'factory_bloc.freezed.dart';

class FactoryBloc extends Bloc<FactoryEvent, FactoryState> {
  final FactoryRepository _repository;

  FactoryBloc(this._repository) : super(const FactoryState.initial()) {
    on<FactoryEvent>((event, emit) async {
      switch (event) {
        case FactoryEventFactoryRequested(:final factoryId):
          emit(const FactoryState.loadInProgress());
          final factoryOrFailure =
              await _repository.getFactory(factoryId: factoryId);
          emit(
            factoryOrFailure.fold(
              (f) => FactoryState.loadFailure(f),
              (factoryBuilding) => FactoryState.loadSuccess(factoryBuilding),
            ),
          );
        case FactoryEventFactoryGot(:final factoryBuilding):
          emit(switch (state) {
            FactoryStateLoadSuccess(:final factoryBuilding) =>
              FactoryState.loadSuccess(
                factoryBuilding.copyWith(
                  inventory: factoryBuilding.inventory,
                ),
              ),
            _ => FactoryState.loadSuccess(factoryBuilding),
          });
      }
    });
  }
}

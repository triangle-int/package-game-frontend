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
  int _revision = 0;

  FactoryBloc(this._repository) : super(const FactoryState.initial()) {
    on<FactoryEvent>((event, emit) async {
      switch (event) {
        case FactoryEventFactoryRequested(:final factoryId):
          final revision = ++_revision;
          if (state is! FactoryStateLoadSuccess) {
            emit(const FactoryState.loadInProgress());
          }
          final factoryOrFailure =
              await _repository.getFactory(factoryId: factoryId);
          if (revision != _revision) return;
          emit(
            factoryOrFailure.fold(
              (f) => state is FactoryStateLoadSuccess
                  ? state
                  : FactoryState.loadFailure(f),
              (factoryBuilding) => FactoryState.loadSuccess(factoryBuilding),
            ),
          );
        case FactoryEventFactoryGot(:final factoryBuilding):
          _revision++;
          emit(switch (state) {
            FactoryStateLoadSuccess(factoryBuilding: final previous) =>
              FactoryState.loadSuccess(
                factoryBuilding.copyWith(
                  inventory: factoryBuilding.inventory ?? previous.inventory,
                ),
              ),
            _ => FactoryState.loadSuccess(factoryBuilding),
          });
      }
    });
  }
}

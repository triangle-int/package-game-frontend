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
      await event.map(
        factoryRequested: (e) async {
          emit(const FactoryState.loadInProgress());
          final factoryOrFailure =
              await _repository.getFactory(factoryId: e.factoryId);
          emit(
            factoryOrFailure.fold(
              (f) => FactoryState.loadFailure(f),
              (factoryBuilding) => FactoryState.loadSuccess(factoryBuilding),
            ),
          );
        },
        factoryGot: (e) async => state.maybeMap(
          loadSuccess: (s) => emit(
            FactoryState.loadSuccess(
              e.factoryBuilding
                  .copyWith(inventory: s.factoryBuilding.inventory),
            ),
          ),
          orElse: () => emit(FactoryState.loadSuccess(e.factoryBuilding)),
        ),
      );
    });
  }
}

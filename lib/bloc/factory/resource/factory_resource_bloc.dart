import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/domain/factory/factory_resource_select_failure.dart';

part 'factory_resource_event.dart';
part 'factory_resource_state.dart';
part 'factory_resource_bloc.freezed.dart';

class FactoryResourceBloc
    extends Bloc<FactoryResourceEvent, FactoryResourceState> {
  final FactoryRepository _factoryRepository;

  FactoryResourceBloc(this._factoryRepository)
      : super(FactoryResourceState.initial()) {
    on<FactoryResourceEvent>((event, emit) async {
      switch (event) {
        case FactoryResourceEventResourceSelected(resource: final resource):
          emit(
            state.copyWith(
              resource: resource,
              failureOrNull: null,
              factoryOrNull: null,
            ),
          );
        case FactoryResourceEventConfirmed(factoryId: final factoryId):
          emit(
            state.copyWith(
              isLoading: true,
              failureOrNull: null,
            ),
          );
          if (state.resource == '') {
            emit(
              state.copyWith(
                isLoading: false,
                failureOrNull:
                    const FactoryResourceSelectFailure.resourceNotSelected(),
              ),
            );
            return;
          }
          final factoryOrFailure = await _factoryRepository.selectResource(
            factoryId,
            state.resource,
          );
          emit(
            factoryOrFailure.fold(
              (f) => state.copyWith(
                isLoading: false,
                failureOrNull: f,
                factoryOrNull: null,
              ),
              (f) => state.copyWith(
                isLoading: false,
                failureOrNull: null,
                factoryOrNull: f,
              ),
            ),
          );
      }
    });
  }
}

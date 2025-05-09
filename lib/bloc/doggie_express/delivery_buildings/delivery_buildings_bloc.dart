import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/truck/delivery_buildings.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';

part 'delivery_buildings_event.dart';
part 'delivery_buildings_state.dart';
part 'delivery_buildings_bloc.freezed.dart';

class DeliveryBuildingsBloc
    extends Bloc<DeliveryBuildingsEvent, DeliveryBuildingsState> {
  final TruckRepository _repository;

  DeliveryBuildingsBloc(this._repository)
      : super(const DeliveryBuildingsState.initial()) {
    on<DeliveryBuildingsEvent>((event, emit) async {
      switch (event) {
        case DeliveryBuildingsEventBuildingsRequested():
          emit(const DeliveryBuildingsState.loadInProgress());
          final targetsOrFailure = await _repository.getDeliveryTargets();
          targetsOrFailure.fold(
            (f) => emit(DeliveryBuildingsState.loadFailure(f)),
            (targets) => emit(DeliveryBuildingsState.loadSuccess(targets)),
          );
      }
    });
  }
}

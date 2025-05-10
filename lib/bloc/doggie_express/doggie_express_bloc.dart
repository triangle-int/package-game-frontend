import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/truck/calculated_path.dart';
import 'package:package_flutter/domain/truck/truck_failure.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';

part 'doggie_express_event.dart';
part 'doggie_express_state.dart';
part 'doggie_express_bloc.freezed.dart';

class DoggieExpressBloc extends Bloc<DoggieExpressEvent, DoggieExpressState> {
  final TruckRepository _repository;

  DoggieExpressBloc(this._repository) : super(DoggieExpressState.initial()) {
    on<DoggieExpressEvent>((event, emit) async {
      switch (event) {
        case DoggieExpressEventTruckTypeUpdated(:final truckType):
          emit(
            state.copyWith(
              truckType: truckType,
              failureOrNull: null,
              path: null,
            ),
          );
        case DoggieExpressEventResourceSelected(:final name):
          emit(
            state.copyWith(
              resource: name,
              amount: BigInt.from(0),
              failureOrNull: null,
              path: null,
            ),
          );
        case DoggieExpressEventAmountEntered(:final amount):
          emit(
            state.copyWith(
              amount: amount,
              failureOrNull: null,
              path: null,
            ),
          );
        case DoggieExpressEventPointASelected(:final point):
          emit(
            state.copyWith(
              pointA: point,
              failureOrNull: null,
              amount: BigInt.from(0),
              resource: '',
              path: null,
            ),
          );
        case DoggieExpressEventPointADeselected():
          emit(
            state.copyWith(
              pointA: null,
              failureOrNull: null,
              amount: BigInt.from(0),
              resource: '',
              path: null,
            ),
          );
        case DoggieExpressEventPointBSelected(:final point):
          emit(
            state.copyWith(
              pointB: point,
              failureOrNull: null,
              amount: BigInt.from(0),
              resource: '',
              path: null,
            ),
          );
        case DoggieExpressEventPointBDeselected():
          emit(
            state.copyWith(
              pointB: null,
              failureOrNull: null,
              amount: BigInt.from(0),
              resource: '',
              path: null,
            ),
          );
        case DoggieExpressEventScheduleDurationUpdated(:final duration):
          emit(
            state.copyWith(
              scheduleDuration: duration,
              failureOrNull: null,
              path: null,
            ),
          );
        case DoggieExpressEventCalculate():
          emit(state.copyWith(isLoading: true, failureOrNull: null));

          if (state.pointA == null) {
            emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: const TruckFailure.pointANotSelected(),
              ),
            );
            return;
          }

          if (state.pointB == null) {
            emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: const TruckFailure.pointBNotSelected(),
              ),
            );
            return;
          }

          if (state.resource == '') {
            emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: const TruckFailure.resourceNotSelected(),
              ),
            );
            return;
          }

          if (state.amount <= BigInt.from(0)) {
            emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: const TruckFailure.amountIsZero(),
              ),
            );
            return;
          }

          final calculatedPathOrFailure = await _repository.calculatePathCost(
            state.pointA!.id,
            state.pointB!.id,
            truckType: state.truckType,
            resourceCount: state.amount.toInt(),
          );

          calculatedPathOrFailure.fold(
            (f) => emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: TruckFailure.serverFailure(f),
              ),
            ),
            (path) => emit(
              state.copyWith(
                isLoading: false,
                path: path,
                failureOrNull: null,
              ),
            ),
          );
        case DoggieExpressEventConfirm():
          emit(
            state.copyWith(
              isLoading: true,
              failureOrNull: null,
              success: false,
            ),
          );

          final unitOrFailure = await _repository.createTruck(
            state.pointA!.id,
            state.pointB!.id,
            truckType: state.truckType,
            resourceCount: state.amount.toInt(),
            scheduleDuration: state.scheduleDuration,
            resourceName: state.resource,
          );

          emit(
            unitOrFailure.fold(
              (f) => state.copyWith(
                isLoading: false,
                success: false,
                failureOrNull: TruckFailure.serverFailure(f),
              ),
              (r) => state.copyWith(
                isLoading: false,
                success: true,
                failureOrNull: null,
              ),
            ),
          );
        case DoggieExpressEventReset():
          emit(DoggieExpressState.initial());
      }
    });
  }
}

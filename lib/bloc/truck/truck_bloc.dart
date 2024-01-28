import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';

part 'truck_event.dart';
part 'truck_state.dart';
part 'truck_bloc.freezed.dart';

class TruckBloc extends Bloc<TruckEvent, TruckState> {
  final TruckRepository _repository;

  StreamSubscription? streamSubscription;

  TruckBloc(this._repository) : super(const TruckState.initial()) {
    on<TruckEvent>((event, emit) async {
      event.map(
        listenTrucksRequested: (_) {
          emit(const TruckState.loadInProgress());

          Logger().d('Loading trucks 🚚');

          streamSubscription?.cancel();
          streamSubscription = _repository.getTrucks().listen(
                (trucksOrFailure) =>
                    add(TruckEvent.trucksReceived(trucksOrFailure)),
              );
        },
        trucksReceived: (e) {
          Logger().d('Trucks loaded 🚚');
          emit(
            e.trucksOrFailure.fold(
              (f) => TruckState.loadFailure(f),
              (trucks) => TruckState.loadSuccess(trucks),
            ),
          );
        },
        truckArrived: (e) {
          _repository.removeTruck(e.truck.id);
        },
      );
    });
  }

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }
}

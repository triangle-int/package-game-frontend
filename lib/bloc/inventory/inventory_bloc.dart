import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/inventory/inventory.dart';
import 'package:package_flutter/domain/inventory/inventory_failure.dart';
import 'package:package_flutter/domain/inventory/inventory_repository.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';
part 'inventory_bloc.freezed.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;

  StreamSubscription? _inventorySubscription;

  InventoryBloc(this._repository) : super(const InventoryState.initial()) {
    on<InventoryEvent>((event, emit) async {
      switch (event) {
        case InventoryEventListenInventoryRequested():
          emit(const InventoryState.loadInProgress());
          _inventorySubscription?.cancel();
          _inventorySubscription =
              _repository.getInventory().listen((itemsOrFailure) {
            itemsOrFailure.fold(
              (failure) => add(InventoryEvent.itemsReceived(left(failure))),
              (items) => add(InventoryEvent.itemsReceived(right(items))),
            );
          });
        case InventoryEventItemsReceived(:final item):
          item.fold(
            (f) => emit(InventoryState.loadFailure(f)),
            (inventory) => emit(InventoryState.loadSuccess(inventory)),
          );
        case InventoryEventReset():
          emit(const InventoryState.initial());
      }
    });
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}

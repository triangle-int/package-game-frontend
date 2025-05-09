part of 'inventory_bloc.dart';

@freezed
sealed class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.listenInventoryRequested() =
      InventoryEventListenInventoryRequested;
  const factory InventoryEvent.itemsReceived(
    Either<InventoryFailure, Inventory> item,
  ) = InventoryEventItemsReceived;
  const factory InventoryEvent.reset() = InventoryEventReset;
}

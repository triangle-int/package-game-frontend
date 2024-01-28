part of 'inventory_bloc.dart';

@freezed
class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.listenInventoryRequested() =
      _ListenInventoryRequested;
  const factory InventoryEvent.itemsReceived(
    Either<InventoryFailure, Inventory> item,
  ) = _ItemsReceived;
  const factory InventoryEvent.reset() = _Reset;
}

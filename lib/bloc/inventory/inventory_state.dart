part of 'inventory_bloc.dart';

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState.initial() = _Initial;
  const factory InventoryState.loadInProgress() = _LoadInProgress;
  const factory InventoryState.loadFailure(InventoryFailure failure) =
      _LoadFailure;
  const factory InventoryState.loadSuccess(Inventory inventory) = _LoadSuccess;
}

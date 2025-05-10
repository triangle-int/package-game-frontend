part of 'inventory_bloc.dart';

// TODO: Convert to state with Either
@freezed
sealed class InventoryState with _$InventoryState {
  const factory InventoryState.initial() = InventoryStateInitial;
  const factory InventoryState.loadInProgress() = InventoryStateLoadInProgress;
  const factory InventoryState.loadFailure(InventoryFailure failure) =
      InventoryStateLoadFailure;
  const factory InventoryState.loadSuccess(Inventory inventory) =
      InventoryStateLoadSuccess;
}

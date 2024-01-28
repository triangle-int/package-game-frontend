import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

@freezed
class Inventory with _$Inventory {
  const Inventory._();

  const factory Inventory({
    required Map<int, List<InventoryItem>> inventory,
  }) = _Inventory;

  // Flat the inventory
  List<InventoryItem> combineInventory() {
    final combinedInventory = <InventoryItem>[];
    for (final storage in inventory.entries) {
      for (final item in storage.value) {
        final index = combinedInventory.indexWhere((i) => i.name == item.name);
        if (index == -1) {
          combinedInventory.add(item);
        } else {
          combinedInventory[index] = combinedInventory[index].copyWith(
            count: combinedInventory[index].count + item.count,
          );
        }
      }
    }

    return combinedInventory;
  }

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);
}

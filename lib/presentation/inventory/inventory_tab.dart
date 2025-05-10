import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/domain/inventory/inventory_failure.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/inventory/inventory_resource.dart';

class InventoryTab extends StatelessWidget {
  final int buildingId;

  const InventoryTab({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, inventoryState) {
        switch (inventoryState) {
          case InventoryStateInitial():
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case InventoryStateLoadInProgress():
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case InventoryStateLoadFailure(:final failure):
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: Center(
                child: Text(
                  'Something went wrong, message: ${switch (failure) {
                    InventoryFailureServerFailure(:final message) => message
                  }}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),
            );
          case InventoryStateLoadSuccess(:final inventory):
            final items = inventory.inventory[buildingId];
            final filteredItems = items == null
                ? <InventoryItem>[]
                : items.where((i) => i.count > BigInt.from(0)).toList();
            filteredItems.sort((a, b) => a.name.compareTo(b.name));
            if (filteredItems.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: const Center(
                  child: Text(
                    'No resources 👎',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 20),
              separatorBuilder: (context, index) => const SizedBox(height: 35),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) =>
                  InventoryResource(filteredItems[index]),
            );
        }
      },
    );
  }
}

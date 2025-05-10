import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/factory/upgrade/factory_upgrade_bloc.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';

class FactoryUpgradeButton extends HookConsumerWidget {
  const FactoryUpgradeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, inventoryState) {
        final inventory = switch (inventoryState) {
          InventoryStateLoadSuccess(:final inventory) => inventory,
          _ => throw const UnexpectedValueError(),
        };
        return BlocBuilder<FactoryBloc, FactoryState>(
          builder: (context, factoryState) {
            final b = switch (factoryState) {
              FactoryStateLoadSuccess(:final factoryBuilding) =>
                factoryBuilding,
              _ => throw const UnexpectedValueError(),
            };

            final hasResource1 = inventory
                    .combineInventory()
                    .firstWhere(
                      (i) => i.name == b.resourceToUpgrade1,
                      orElse: () => InventoryItem(
                        name: b.resourceToUpgrade1!,
                        count: BigInt.from(0),
                      ),
                    )
                    .count >=
                BigInt.from(config.factoryUpgradeCosts[b.level - 1]);
            final hasResource2 = inventory
                    .combineInventory()
                    .firstWhere(
                      (i) => i.name == b.resourceToUpgrade2,
                      orElse: () => InventoryItem(
                        name: b.resourceToUpgrade2!,
                        count: BigInt.from(0),
                      ),
                    )
                    .count >=
                BigInt.from(config.factoryUpgradeCosts[b.level - 1]);
            final hasResource3 = inventory
                    .combineInventory()
                    .firstWhere(
                      (i) => i.name == b.resourceToUpgrade3,
                      orElse: () => InventoryItem(
                        name: b.resourceToUpgrade3!,
                        count: BigInt.from(0),
                      ),
                    )
                    .count >=
                BigInt.from(config.factoryUpgradeCosts[b.level - 1]);

            final canUpgrade = hasResource1 && hasResource2 && hasResource3;

            return ElevatedButton(
              onPressed: () {
                if (canUpgrade) {
                  context
                      .read<FactoryUpgradeBloc>()
                      .add(FactoryUpgradeEvent.factoryUpgraded(b));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(130),
                ),
                fixedSize: const Size(240, 49),
              ),
              child: const Text(
                'upgrade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

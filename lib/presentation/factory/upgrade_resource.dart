import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';

class UpgradeResource extends HookConsumerWidget {
  final String resourceName;

  const UpgradeResource({super.key, required this.resourceName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<FactoryBloc, FactoryState>(
      builder: (context, factoryState) {
        final factoryBuilding = factoryState.maybeMap(
          loadSuccess: (s) => s.factoryBuilding,
          orElse: () => throw const UnexpectedValueError(),
        );
        return BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            final needResources =
                config.factoryUpgradeCosts[factoryBuilding.level - 1];
            final currentResources = inventoryState.maybeMap(
              loadSuccess: (inventoryState) => inventoryState.inventory
                  .combineInventory()
                  .firstWhere(
                    (i) => i.name == resourceName,
                    orElse: () => InventoryItem(
                      name: resourceName,
                      count: BigInt.from(0),
                    ),
                  )
                  .count,
              orElse: () => BigInt.from(0),
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                EmojiImage(
                  emoji: config.items
                      .firstWhere((i) => i.name == resourceName)
                      .emoji,
                  size: 42,
                ),
                const SizedBox(width: 10),
                Text(
                  '${currentResources.toCurrency()} / ${needResources.toCurrency()}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: currentResources >= BigInt.from(needResources)
                        ? Colors.white
                        : const Color(0xFF9F9F9F),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

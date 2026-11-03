import 'package:package_flutter/l10n/app_text.dart';
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
        final factoryBuilding = switch (factoryState) {
          FactoryStateLoadSuccess(:final factoryBuilding) => factoryBuilding,
          _ => throw const UnexpectedValueError(),
        };
        return BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            final needResources =
                config.factoryUpgradeCosts[factoryBuilding.level - 1];
            final currentResources = switch (inventoryState) {
              InventoryStateLoadSuccess(:final inventory) => inventory
                  .combineInventory()
                  .firstWhere(
                    (i) => i.name == resourceName,
                    orElse: () => InventoryItem(
                      name: resourceName,
                      count: BigInt.from(0),
                    ),
                  )
                  .count,
              _ => BigInt.from(0),
            };
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  EmojiImage(
                      emoji: config.getItemByName(resourceName).emoji,
                      size: 22),
                  const SizedBox(width: 4),
                  Expanded(
                    child: AppText(
                      '${currentResources.toCurrency()}/${needResources.toCurrency()}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: currentResources >= BigInt.from(needResources)
                            ? Colors.white
                            : const Color(0xFF9F9F9F),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

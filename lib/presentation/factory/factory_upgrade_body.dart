import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/factory/upgrade/factory_upgrade_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';
import 'package:package_flutter/presentation/factory/factory_upgrade_button.dart';
import 'package:package_flutter/presentation/factory/upgrade_resource.dart';

class FactoryUpgradeBody extends HookConsumerWidget {
  const FactoryUpgradeBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocListener<FactoryUpgradeBloc, FactoryUpgradeState>(
      listener: (context, upgradeState) {
        upgradeState.map(
          initial: (_) {},
          loadInProgress: (_) {},
          loadSuccess: (s) => context
              .read<FactoryBloc>()
              .add(FactoryEvent.factoryGot(s.building)),
          loadFailure: (s) => context
              .read<NotificationsBloc>()
              .add(NotificationsEvent.warningAdded(s.failure.getMessage())),
        );
      },
      child: BlocBuilder<FactoryBloc, FactoryState>(
        builder: (context, factoryState) {
          final factoryBuilding = factoryState.maybeMap(
            loadSuccess: (f) => f.factoryBuilding,
            orElse: () => throw const UnexpectedValueError(),
          );
          final productionItem = config.items
              .firstWhere(
                (i) => i.name == factoryBuilding.currentResource,
                orElse: () => Item.unknown(
                  name: factoryBuilding.currentResource!,
                ),
              )
              .emoji;
          final inInventory = factoryBuilding.inventory == null
              ? BigInt.from(0)
              : factoryBuilding.inventory!
                  .firstWhere(
                    (i) => i.name == factoryBuilding.currentResource,
                    orElse: () =>
                        InventoryItem(name: '', count: BigInt.from(0)),
                  )
                  .count;
          final differenceInSpeed = ref
                  .read(activatedBoostersProvider.notifier)
                  .getBoostedFactoryProduction(
                      config.factoryResourcesPerMinute[factoryBuilding.level]) -
              ref
                  .read(activatedBoostersProvider.notifier)
                  .getBoostedFactoryProduction(config
                      .factoryResourcesPerMinute[factoryBuilding.level - 1]);
          final factoryLimit = config.factoryResourcesLimit;

          return Column(
            children: [
              UpgradeResource(
                resourceName: factoryBuilding.resourceToUpgrade1!,
              ),
              const SizedBox(height: 5),
              UpgradeResource(
                resourceName: factoryBuilding.resourceToUpgrade2!,
              ),
              const SizedBox(height: 5),
              UpgradeResource(
                resourceName: factoryBuilding.resourceToUpgrade3!,
              ),
              const SizedBox(height: 13),
              Center(
                child: Text(
                  'In: ${inInventory.toCurrency()} $productionItem / ${factoryLimit.toCurrency()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              BlocConsumer<FactoryUpgradeBloc, FactoryUpgradeState>(
                listener: (context, upgradeState) {
                  upgradeState.mapOrNull(
                    loadSuccess: (_) {
                      AudioPlayer().play(
                        AssetSource('sounds/factory_upgrade.wav'),
                      );
                      context.router.pop();
                    },
                  );
                },
                builder: (context, upgradeState) {
                  return upgradeState.map(
                    initial: (_) => const FactoryUpgradeButton(),
                    loadInProgress: (_) => const SizedBox(
                      width: 49,
                      height: 49,
                      child: CircularProgressIndicator(),
                    ),
                    loadSuccess: (_) => const FactoryUpgradeButton(),
                    loadFailure: (_) => const FactoryUpgradeButton(),
                  );
                },
              ),
              const SizedBox(height: 11),
              Center(
                child: Text(
                  '+$differenceInSpeed $productionItem/min',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

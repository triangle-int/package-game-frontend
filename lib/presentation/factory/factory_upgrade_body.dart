import 'package:package_flutter/l10n/app_text.dart';
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
        switch (upgradeState) {
          case FactoryUpgradeStateInitial():
            break;
          case FactoryUpgradeStateLoadInProgress():
            break;
          case FactoryUpgradeStateLoadSuccess(:final building):
            context.read<FactoryBloc>().add(FactoryEvent.factoryGot(building));
          case FactoryUpgradeStateLoadFailure(:final failure):
            context
                .read<NotificationsBloc>()
                .add(NotificationsEvent.warningAdded(failure.getMessage()));
        }
      },
      child: BlocBuilder<FactoryBloc, FactoryState>(
        builder: (context, factoryState) {
          final factoryBuilding = switch (factoryState) {
            FactoryStateLoadSuccess(:final factoryBuilding) => factoryBuilding,
            _ => throw const UnexpectedValueError(),
          };
          final maxLevel = factoryBuilding.level >=
                  config.factoryUpgradeCosts.length ||
              factoryBuilding.level >= config.factoryResourcesPerMinute.length;
          if (maxLevel) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AppText('This factory has reached its maximum level.'),
            );
          }
          final currentSpeed = ref
              .read(activatedBoostersProvider.notifier)
              .getBoostedFactoryProduction(
                config.factoryResourcesPerMinute[factoryBuilding.level - 1],
              );
          final nextSpeed = ref
              .read(activatedBoostersProvider.notifier)
              .getBoostedFactoryProduction(
                config.factoryResourcesPerMinute[factoryBuilding.level],
              );

          return Column(
            children: [
              const AppText('Materials:',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: UpgradeResource(
                          resourceName: factoryBuilding.resourceToUpgrade1!)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: UpgradeResource(
                          resourceName: factoryBuilding.resourceToUpgrade2!)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: UpgradeResource(
                          resourceName: factoryBuilding.resourceToUpgrade3!)),
                ],
              ),
              const SizedBox(height: 13),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppText('Production:',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
              ),
              const SizedBox(height: 4),
              AppText(
                '$currentSpeed/min  →  $nextSpeed/min',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 13),
              BlocConsumer<FactoryUpgradeBloc, FactoryUpgradeState>(
                listener: (context, upgradeState) {
                  switch (upgradeState) {
                    case FactoryUpgradeStateLoadSuccess():
                      AudioPlayer().play(
                        AssetSource('sounds/factory_upgrade.wav'),
                      );
                      context.router.pop();
                    default:
                      break;
                  }
                },
                builder: (context, upgradeState) {
                  return switch (upgradeState) {
                    FactoryUpgradeStateInitial() =>
                      const FactoryUpgradeButton(),
                    FactoryUpgradeStateLoadInProgress() => const SizedBox(
                        width: 49,
                        height: 49,
                        child: CircularProgressIndicator(),
                      ),
                    FactoryUpgradeStateLoadSuccess() =>
                      const FactoryUpgradeButton(),
                    FactoryUpgradeStateLoadFailure() =>
                      const FactoryUpgradeButton(),
                  };
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

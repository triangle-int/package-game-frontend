import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/factory/toggle/factory_toggle_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/presentation/factory/factory_header.dart';
import 'package:package_flutter/presentation/factory/factory_select_resource.dart';
import 'package:package_flutter/presentation/factory/factory_upgrade_body.dart';
import 'package:package_flutter/presentation/market/market_loading.dart';

class FactoryMenu extends HookConsumerWidget {
  final int factoryId;

  const FactoryMenu({
    super.key,
    required this.factoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FactoryBloc(ref.watch(factoryRepositoryProvider))
            ..add(FactoryEvent.factoryRequested(factoryId)),
        ),
        BlocProvider(
          create: (context) =>
              FactoryToggleBloc(ref.watch(factoryRepositoryProvider)),
        ),
      ],
      child: BlocBuilder<FactoryBloc, FactoryState>(
        builder: (context, factoryState) {
          final config = ref.watch(configProvider).value!;
          return Center(
            child: Container(
              width: 334,
              height: 470,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Builder(builder: (context) {
                switch (factoryState) {
                  case FactoryStateInitial():
                    return const MarketLoading();
                  case FactoryStateLoadInProgress():
                    return const MarketLoading();
                  case FactoryStateLoadFailure():
                    return Center(
                      child: Text(
                        "Something isn't right: ${factoryState.f.getMessage()}",
                      ),
                    );
                  case FactoryStateLoadSuccess(:final factoryBuilding):
                    final hasProductionItem =
                        factoryBuilding.currentResource != null;
                    final productionItem = hasProductionItem
                        ? config.items
                            .firstWhere(
                              (i) => i.name == factoryBuilding.currentResource,
                              orElse: () => Item.unknown(
                                name: factoryBuilding.currentResource!,
                              ),
                            )
                            .emoji
                        : '🏭';
                    final enabled = factoryBuilding.enabled;
                    final productionSpeed = ref
                        .read(activatedBoostersProvider.notifier)
                        .getBoostedFactoryProduction(
                          config.factoryResourcesPerMinute[
                              factoryBuilding.level - 1],
                        );

                    if (factoryBuilding.ownerId != user.id) {
                      return Center(
                        child: Text(
                          '${factoryBuilding.owner?.avatar} ${factoryBuilding.owner?.nickname}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        FactoryHeader(
                          productionItem: productionItem,
                          productionSpeed: productionSpeed,
                          factoryBuilding: factoryBuilding,
                          hasProductionItem: hasProductionItem,
                          enabled: enabled,
                        ),
                        if (hasProductionItem) ...[
                          const FactoryUpgradeBody(),
                        ] else ...[
                          FactorySelectResource(factoryId: factoryId),
                        ]
                      ],
                    );
                }
              }),
            ),
          );
        },
      ),
    );
  }
}

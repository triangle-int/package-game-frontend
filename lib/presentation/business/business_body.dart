import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/bloc/business/business_bloc.dart';
import 'package:package_flutter/bloc/business/upgrade/business_upgrade_bloc.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/get_business_response.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';

class BusinessBody extends HookConsumerWidget {
  const BusinessBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, businessState) {
        final businessAndTaxes = switch (businessState) {
          BusinessStateLoadSuccess(:final businessAndTax) => businessAndTax,
          _ => GetBusinessResponse(
              business: Building.business(
                id: 0,
                geohex: '',
                geohash: '',
                level: 0,
                ownerId: 0,
                updatedAt: DateTime.now(),
                resourceToUpgrade1: 'wheel',
              ) as BusinessBuilding,
              tax: 0,
            ),
        };

        final income = ref
            .read(activatedBoostersProvider.notifier)
            .getBoostedIncome(
              config
                  .businessMoneyPerMinute[businessAndTaxes.business.level - 1],
            );
        final taxes = (income * businessAndTaxes.tax).floor();
        final businessCost =
            ref.read(activatedBoostersProvider.notifier).getBoostedCost(
                  config.businessCosts.length > businessAndTaxes.business.level
                      ? config.businessCosts[businessAndTaxes.business.level]
                      : 0,
                );
        final resourceToUpgrade = config
            .getItemByName(businessAndTaxes.business.resourceToUpgrade1!)
            .emoji;
        final businessEmoji =
            config.getBusinessEmoji(businessAndTaxes.business.level);
        final isMaxLevel = config.businessMoneyPerMinute.length <=
            businessAndTaxes.business.level;
        return Container(
          height: 312 + 60,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                color: Theme.of(context).colorScheme.background,
                height: 312,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60 + 12),
                child: Column(
                  children: [
                    Text(
                      'Level ${businessAndTaxes.business.level}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Sansation',
                        fontSize: 48,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'income: ${income.toCurrency()}(${taxes.toCurrency()} taxes)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 15),
                    BlocBuilder<BusinessUpgradeBloc, BusinessUpgradeState>(
                      builder: (context, upgradeState) {
                        return switch (upgradeState) {
                          LoadInProgress() => const CircularProgressIndicator(),
                          _ => UpgradeButton(
                              businessAndTaxes: businessAndTaxes,
                              businessCost: businessCost,
                              isMaxLevel: isMaxLevel,
                              resourceToUpgradeEmoji: resourceToUpgrade,
                            ),
                        };
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                    border: Border.all(
                      width: 12,
                      color: const Color(0xFF373EBA),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: EmojiImage(emoji: businessEmoji),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UpgradeButton extends StatelessWidget {
  const UpgradeButton({
    super.key,
    required this.businessAndTaxes,
    required this.businessCost,
    required this.isMaxLevel,
    required this.resourceToUpgradeEmoji,
  });

  final bool isMaxLevel;
  final GetBusinessResponse businessAndTaxes;
  final int businessCost;
  final String resourceToUpgradeEmoji;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, inventoryState) {
        final inventory = switch (inventoryState) {
          InventoryStateLoadSuccess(:final inventory) =>
            inventory.combineInventory(),
          _ => throw const UnexpectedValueError(),
        };
        final resourceCount = inventory.firstWhere(
          (i) => i.name == businessAndTaxes.business.resourceToUpgrade1,
          orElse: () => InventoryItem(
            name: businessAndTaxes.business.resourceToUpgrade1!,
            count: BigInt.from(0),
          ),
        );
        return ElevatedButton(
          onPressed:
              isMaxLevel || resourceCount.count < BigInt.from(businessCost)
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      context.read<BusinessUpgradeBloc>().add(
                            BusinessUpgradeEvent.upgradeRequested(
                              businessAndTaxes.business,
                            ),
                          );
                    },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(37),
            ),
          ),
          child: Text(
            isMaxLevel
                ? 'max level'
                : 'upgrade ${businessCost.toCurrency()}$resourceToUpgradeEmoji',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
        );
      },
    );
  }
}

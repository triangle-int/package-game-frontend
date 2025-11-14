import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/booster/booster_activate_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/state_national_marketplace/help_dialog.dart';

class InventoryResource extends HookConsumerWidget {
  final InventoryItem item;

  const InventoryResource(this.item, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;
    final itemConfig = config.items.firstWhere(
      (i) => i.name == item.name,
      orElse: () => const Item.unknown(name: 'unknown'),
    );
    final color = switch (itemConfig) {
      ItemResource(:final color) => Color(
          0xFF000000 + int.parse(color, radix: 16),
        ),
      ItemBooster() => Theme.of(context).colorScheme.surface,
      ItemUnknown() => Colors.white,
    };

    ref.listen<AsyncValue>(
      boosterActivateProvider(itemConfig.name),
      (previous, next) {
        next.when(
          data: (_) => Logger().d('Booster activated!'),
          error: (e, st) =>
              Logger().e('Booster activation error!', error: e, stackTrace: st),
          loading: () {},
        );
      },
    );

    return Center(
      child: Container(
        width: 371,
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(11)),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'On storage: ${item.count.toCurrency()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (itemConfig is ItemBooster)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ref
                      .watch(boosterActivateProvider(itemConfig.name))
                      .isLoading) ...[
                    const CircularProgressIndicator(),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(
                              boosterActivateProvider(itemConfig.name).notifier,
                            )
                            .activate();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'use',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => HelpDialog(
                            text: itemConfig.description.replaceAll(
                              '{duration}',
                              '${config.boosterDuration} hour',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      child: const Icon(Icons.question_mark_rounded),
                    ),
                  ],
                ],
              ),
            const SizedBox(width: 10),
            // Emoji image
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(11),
              ),
              padding: const EdgeInsets.all(10),
              child: EmojiImage(emoji: itemConfig.emoji),
            ),
          ],
        ),
      ),
    );
  }
}

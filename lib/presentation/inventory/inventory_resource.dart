import 'package:package_flutter/l10n/translations.dart';
import 'package:package_flutter/l10n/app_text.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * .9;
        final cardHeight = cardWidth * .135;
        final radius = BorderRadius.circular(cardHeight * .11);

        return Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: radius,
            ),
            child: Row(
              children: [
                SizedBox(width: cardWidth * .05),
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: AppText(
                      'On storage: ${item.count.toCurrency()}',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: cardHeight * .32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (itemConfig is ItemBooster)
                  if (ref
                      .watch(boosterActivateProvider(itemConfig.name))
                      .isLoading)
                    SizedBox.square(
                      dimension: cardHeight,
                      child: Padding(
                        padding: EdgeInsets.all(cardHeight * .25),
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    SizedBox.square(
                      dimension: cardHeight,
                      child: Tooltip(
                        message: translate(context, 'Use booster'),
                        child: Padding(
                          padding: EdgeInsets.all(cardHeight * .08),
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(cardHeight),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(cardHeight),
                              onTap: () => ref
                                  .read(boosterActivateProvider(itemConfig.name)
                                      .notifier)
                                  .activate(),
                              child: Center(
                                child: AppText(
                                  'use',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: cardHeight * .3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox.square(
                      dimension: cardHeight,
                      child: Tooltip(
                        message: translate(context, 'About booster'),
                        child: Padding(
                          padding: EdgeInsets.all(cardHeight * .08),
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(cardHeight),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(cardHeight),
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => HelpDialog(
                                  text: itemConfig.description.replaceAll(
                                    '{duration}',
                                    '${config.boosterDuration} hour',
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.question_mark_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: cardHeight * .42,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                SizedBox(width: cardHeight * .1),
                SizedBox.square(
                  dimension: cardHeight,
                  child: Container(
                    decoration:
                        BoxDecoration(color: color, borderRadius: radius),
                    padding: EdgeInsets.all(cardHeight * .1),
                    child: EmojiImage(emoji: itemConfig.emoji),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

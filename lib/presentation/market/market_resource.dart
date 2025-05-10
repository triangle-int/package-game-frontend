import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/market/market_bloc.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';

class MarketResource extends HookConsumerWidget {
  const MarketResource({super.key, required this.resourceLevel});

  final int resourceLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, marketState) {
        final config = ref.watch(configProvider).value!;
        final group = switch (marketState) {
          MarketStateLoadSuccess(:final market) => market.level,
          _ => throw const UnexpectedValueError(),
        };
        final item = config.items.whereType<ItemResource>().firstWhere(
              (i) => i.level == resourceLevel && i.group == group,
            );
        final count = switch (marketState) {
          MarketStateLoadSuccess(:final market) => market.inventory!
              .firstWhere(
                (i) => i.name == item.name,
                orElse: () => InventoryItem(
                  name: item.name,
                  count: BigInt.from(0),
                ),
              )
              .count,
        };

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmojiImage(emoji: item.emoji, size: 37),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

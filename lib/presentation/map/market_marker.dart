import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class MarketMarker extends HookConsumerWidget {
  final MarketBuilding b;

  const MarketMarker(
    this.b, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    final color = config.items
        .whereType<ItemResource>()
        .firstWhere((i) => i.group == b.level && i.level == 8)
        .color;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmojiImage(
            size: 30,
            emoji: '🏬',
          ),
          Container(
            height: 5,
            width: 30,
            color: Color(0xFF000000 + int.parse(color, radix: 16)),
          )
        ],
      ),
    );
  }
}

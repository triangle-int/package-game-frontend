import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class BusinessMarker extends HookConsumerWidget {
  const BusinessMarker(
    this.iconName,
    this.building, {
    super.key,
  });

  final String iconName;
  final BusinessBuilding building;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;
    final user = ref.watch(userProvider).value!;

    return Stack(
      children: [
        Image.asset(
          'assets/images/buildings/$iconName.png',
        ),
        if (user.id == building.ownerId)
          Positioned(
            top: 5,
            right: 5,
            width: 15,
            height: 15,
            child: EmojiImage(
              emoji: config.items
                  .firstWhere(
                    (i) => i.name == building.resourceToUpgrade1,
                    orElse: () => const Item.unknown(name: 'unknown'),
                  )
                  .emoji,
            ),
          ),
      ],
    );
  }
}

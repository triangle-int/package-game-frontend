import 'package:package_flutter/l10n/translations.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/bloc/map/map_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/inventory/inventory_body.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class Inventory extends HookConsumerWidget {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed &&
          previous == AppLifecycleState.paused) {
        context
            .read<InventoryBloc>()
            .add(const InventoryEvent.listenInventoryRequested());
      }
    });

    final user = ref.watch(userProvider).value!;
    final levels = ref.watch(configProvider).value!.expreienceForLevel;
    final isMaxLevel = user.level >= levels.length;
    final experienceForLevel =
        isMaxLevel ? BigInt.zero : BigInt.from(levels[user.level]);
    final remainingExperience = user.experience >= experienceForLevel
        ? BigInt.zero
        : experienceForLevel - user.experience;

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 83,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF979797),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              Tooltip(
                  message:
                      translate(context, 'Center the map on your location'),
                  child: TouchableOpacity(
                    onTap: () => BlocProvider.of<MapBloc>(context)
                        .add(const MapEvent.movedToPlayer()),
                    child: EmojiImage(
                      emoji: user.avatar,
                      size: 40,
                    ),
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF80D8FF),
                            shape: BoxShape.circle,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AppText(
                              (user.level + 1).toCurrency(),
                              style: const TextStyle(
                                color: Color(0xFF142D3A),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    AppText(
                      isMaxLevel
                          ? 'Maximum level'
                          : '${remainingExperience.toCurrency()} 🎖️ left',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
        BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            return switch (inventoryState) {
              InventoryStateLoadSuccess(:final inventory) =>
                InventoryBody(inventory: inventory),
              InventoryStateLoadFailure() => const Expanded(
                  child: Center(child: AppText('Could not load inventory.')),
                ),
              _ => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
            };
          },
        ),
      ],
    );
  }
}

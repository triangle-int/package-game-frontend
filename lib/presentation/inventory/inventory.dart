import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/bloc/map/map_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';
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
    final money = user.money.toCurrency();
    final gems = user.gems.toCurrency();

    return Column(
      children: [
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 83,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF979797),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  '$money 💵',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              TouchableOpacity(
                onTap: () => BlocProvider.of<MapBloc>(context)
                    .add(const MapEvent.movedToPlayer()),
                child: EmojiImage(
                  emoji: user.avatar,
                  size: 48,
                ),
              ),
              Expanded(
                child: Text(
                  '$gems 💎',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            return InventoryBody(
              inventory: inventoryState.maybeMap(
                loadSuccess: (s) => s.inventory,
                orElse: () => throw const UnexpectedValueError(),
              ),
            );
          },
        ),
      ],
    );
  }
}

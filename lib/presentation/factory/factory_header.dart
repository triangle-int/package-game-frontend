import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/factory/toggle/factory_toggle_bloc.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/factory/factory_toggle_button.dart';

class FactoryHeader extends StatelessWidget {
  const FactoryHeader({
    super.key,
    required this.productionItem,
    required this.factoryBuilding,
    required this.hasProductionItem,
    required this.productionSpeed,
    required this.enabled,
  });

  final String productionItem;
  final int productionSpeed;
  final FactoryBuilding factoryBuilding;
  final bool hasProductionItem;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FactoryToggleBloc, FactoryToggleState>(
      listener: (context, state) {
        state.maybeMap(
          loadSuccess: (s) {
            context
                .read<FactoryBloc>()
                .add(FactoryEvent.factoryGot(s.building));
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmojiImage(emoji: productionItem, size: 120),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Level ${factoryBuilding.level}',
                    style: const TextStyle(
                      fontFamily: 'Sansation',
                      fontSize: 40,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    hasProductionItem
                        ? '$productionSpeed $productionItem/min'
                        : '0/min',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FactoryToggleButton(
                    factoryBuilding: factoryBuilding,
                    hasProductionItem: hasProductionItem,
                    enabled: enabled,
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

import 'package:package_flutter/l10n/translations.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/factory/toggle/factory_toggle_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
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
        switch (state) {
          case FactoryToggleStateLoadSuccess(:final building):
            context.read<FactoryBloc>().add(FactoryEvent.factoryGot(building));
          case FactoryToggleStateLoadFailure(:final f):
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.warningAdded(f.getMessage()),
                );
          default:
            break;
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const EmojiImage(emoji: '🏭', size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppText(
                            'Factory',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xff4387d8),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${factoryBuilding.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: translate(context, 'Factory information'),
                            icon: const Icon(Icons.help_outline, size: 20),
                            onPressed: () => _showInfo(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (hasProductionItem)
                        Row(
                          children: [
                            EmojiImage(emoji: productionItem, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              '— $productionSpeed/min',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        )
                      else
                        const AppText('Choose a resource to begin'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppText(
                    !hasProductionItem
                        ? 'Select a resource to enable production'
                        : enabled
                            ? 'Production is on'
                            : 'Production is paused',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                FactoryToggleButton(
                  factoryBuilding: factoryBuilding,
                  hasProductionItem: hasProductionItem &&
                      state is! FactoryToggleStateLoadInProgress,
                  enabled: enabled,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Factory information'),
        content: const SingleChildScrollView(
          child: AppText(
            'Running costs are charged daily. Production pauses if you cannot pay.\n\n'
            'Factory stock is separate from your warehouses. Send finished goods to a warehouse with Doggie Express.\n\n'
            'Upgrade materials must be stored in your warehouses. Upgrades improve production speed and unlock the next resource in this production chain.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AppText('Close'),
          ),
        ],
      ),
    );
  }
}

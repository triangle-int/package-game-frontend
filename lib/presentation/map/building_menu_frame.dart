import 'package:flutter/material.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_owner.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:package_flutter/presentation/map/destory_dialog.dart';

Future<void> showBuildingMenuSheet({
  required BuildContext context,
  required Building building,
  required User currentUser,
  required String buildingEmoji,
  Widget? details,
}) {
  final ownerId = _ownerIdOf(building);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => BuildingMenuFrame(
      building: building,
      currentUser: currentUser,
      buildingEmoji: buildingEmoji,
      canDelete: ownerId == currentUser.id,
      details: details,
    ),
  );
}

class BuildingMenuFrame extends StatelessWidget {
  const BuildingMenuFrame({
    super.key,
    required this.building,
    required this.currentUser,
    required this.buildingEmoji,
    required this.canDelete,
    this.details,
  });

  final Building building;
  final User currentUser;
  final String buildingEmoji;
  final bool canDelete;
  final Widget? details;

  @override
  Widget build(BuildContext context) {
    final hasExpandedContent = details != null || canDelete;

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.18,
      initialChildSize: 0.24,
      maxChildSize: hasExpandedContent ? 0.9 : 0.3,
      snap: true,
      snapSizes: hasExpandedContent ? const [0.24, 0.9] : const [0.24],
      snapAnimationDuration: const Duration(milliseconds: 220),
      builder: (context, scrollController) {
        return Material(
          key: const Key('building-menu-sheet'),
          color: Theme.of(context).colorScheme.surface,
          elevation: 16,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      key: const Key('building-menu-drag-handle'),
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              buildingEmoji,
                              style: const TextStyle(fontSize: 38),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppText(
                                _titleOf(building),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                'Level ${building.level}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                _ownerLabel(building, currentUser),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (hasExpandedContent) ...[
                                const SizedBox(height: 4),
                                const AppText(
                                  'Pull up for details',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  if (hasExpandedContent) ...[
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    if (details case final details?) details,
                    if (canDelete)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final removed = await showDialog<bool>(
                              context: context,
                              builder: (_) => DestroyDialog(building: building),
                            );
                            if (removed == true && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const AppText('Demolish'),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

int? _ownerIdOf(Building building) => switch (building) {
      BusinessBuilding(:final ownerId) => ownerId,
      StorageBuilding(:final ownerId) => ownerId,
      FactoryBuilding(:final ownerId) => ownerId,
      MarketBuilding() => null,
      SatelliteBuilding(:final ownerId) => ownerId,
    };

BuildingOwner? _ownerOf(Building building) => switch (building) {
      BusinessBuilding(:final owner) => owner,
      StorageBuilding(:final owner) => owner,
      FactoryBuilding(:final owner) => owner,
      MarketBuilding() => null,
      SatelliteBuilding(:final owner) => owner,
    };

String _titleOf(Building building) => switch (building) {
      BusinessBuilding() => 'Business',
      StorageBuilding() => 'Warehouse',
      FactoryBuilding() => 'Factory',
      MarketBuilding(:final level) => '${[
          'Auto',
          'Music',
          'Tech',
          'Boat',
          'Bread',
        ][(level - 1).clamp(0, 4)]} market',
      SatelliteBuilding() => 'Satellite',
    };

String _ownerLabel(Building building, User currentUser) {
  final ownerId = _ownerIdOf(building);
  if (ownerId == null) return 'Public market';
  if (ownerId == currentUser.id) {
    return '${currentUser.avatar} ${currentUser.nickname} · your building';
  }

  final owner = _ownerOf(building);
  return owner == null
      ? 'Owned by another player'
      : 'Owned by ${owner.avatar} ${owner.nickname}';
}

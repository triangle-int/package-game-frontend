import 'package:package_flutter/l10n/app_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/building/building_bloc.dart';
import 'package:package_flutter/bloc/map/build_panel/build_panel_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:package_flutter/presentation/map/build_panel_item.dart';
import 'package:package_flutter/presentation/map/destory_dialog.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BuildPanel extends HookConsumerWidget {
  final PanelController panelController;
  final void Function(LatLng location, BigInt amount) onCurrencyChange;

  BuildPanel({
    super.key,
    required this.panelController,
    required this.onCurrencyChange,
  });

  final _buyAudioPlayer = AudioPlayer();

  void _showBuildingList(BuildContext context, int ownerId, Config config) {
    final buildings = context
        .read<BuildingBloc>()
        .state
        .buildings
        .where((building) => switch (building) {
              MarketBuilding() => false,
              SatelliteBuilding() => building.ownerId == ownerId,
              BusinessBuilding() => building.ownerId == ownerId,
              StorageBuilding() => building.ownerId == ownerId,
              FactoryBuilding() => building.ownerId == ownerId,
            })
        .toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: buildings.length,
          itemBuilder: (_, index) {
            final building = buildings[index];
            return ListTile(
              leading: Text(building.getEmoji(config)),
              title: AppText(
                switch (building) {
                  FactoryBuilding() => 'Factory · Level ${building.level}',
                  StorageBuilding() => 'Warehouse · Level ${building.level}',
                  BusinessBuilding() => 'Business · Level ${building.level}',
                  SatelliteBuilding() => 'Satellite · Level ${building.level}',
                  MarketBuilding() => 'Market',
                },
              ),
              trailing:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showDialog(
                  context: context,
                  builder: (_) => DestroyDialog(building: building),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;
    final config = ref.watch(configProvider).value!;
    final money = user.money;
    final isBuilding = useState(false);
    final pendingTutorialEvent = useRef<TutorialEvent?>(null);
    final pendingSound = useRef<String?>(null);
    final pendingCurrencyChange =
        useRef<({LatLng location, BigInt amount})?>(null);

    void submit(
      BuildPanelEvent event,
      String sound, {
      required LatLng location,
      required int price,
      TutorialEvent? tutorial,
    }) {
      if (isBuilding.value) return;
      isBuilding.value = true;
      pendingTutorialEvent.value = tutorial;
      pendingSound.value = sound;
      pendingCurrencyChange.value = (
        location: location,
        amount: -BigInt.from(price),
      );
      context.read<BuildPanelBloc>().add(event);
      panelController.close();
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<BuildPanelBloc, BuildPanelState>(
          listener: (context, state) {
            switch (state) {
              case BuildPanelStateLoadFailure(:final failure):
                isBuilding.value = false;
                pendingTutorialEvent.value = null;
                pendingSound.value = null;
                pendingCurrencyChange.value = null;
                context
                    .read<NotificationsBloc>()
                    .add(NotificationsEvent.warningAdded(failure.getMessage()));
              case BuildPanelStateLoadSuccess():
                isBuilding.value = false;
                final tutorialEvent = pendingTutorialEvent.value;
                final sound = pendingSound.value;
                final currencyChange = pendingCurrencyChange.value;
                pendingTutorialEvent.value = null;
                pendingSound.value = null;
                pendingCurrencyChange.value = null;
                if (sound != null) _buyAudioPlayer.play(AssetSource(sound));
                if (currencyChange != null) {
                  onCurrencyChange(
                    currencyChange.location,
                    currencyChange.amount,
                  );
                }
                if (tutorialEvent != null) {
                  context.read<TutorialBloc>().add(tutorialEvent);
                }
              default:
                break;
            }
          },
        ),
      ],
      child: BlocBuilder<PinMarkerBloc, PinMarkerState>(
        builder: (context, pinMarkerState) {
          final boosters = ref.read(activatedBoostersProvider.notifier);
          final currencyLocation = LatLng(
            pinMarkerState.cell.lat,
            pinMarkerState.cell.lon,
          );
          final businessPrice =
              boosters.getBoostedCost(config.businessCosts[0]);
          final storagePrice = boosters.getBoostedCost(config.storageCost);
          final factoryPrice = boosters.getBoostedCost(config.factoryCost);
          final satellite1Price =
              boosters.getBoostedCost(config.satelliteCosts[0]);
          final satellite2Price =
              boosters.getBoostedCost(config.satelliteCosts[1]);
          final satellite3Price =
              boosters.getBoostedCost(config.satelliteCosts[2]);
          final canBuildBusiness = BigInt.from(businessPrice) <= money;
          final canBuildStorage = BigInt.from(storagePrice) <= money;
          final canBuildFactory = BigInt.from(factoryPrice) <= money;
          final canBuildSatellite1 = BigInt.from(satellite1Price) <= money;
          final canBuildSatellite2 = BigInt.from(satellite2Price) <= money;
          final canBuildSatellite3 = BigInt.from(satellite3Price) <= money;
          return BlocBuilder<TutorialBloc, TutorialState>(
            builder: (context, tutorialState) {
              final showBusiness = tutorialState.step
                  .isAfterOrEqual(const TutorialStep.hidden());
              final showStorage = tutorialState.step
                  .isAfterOrEqual(const TutorialStep.openBuildMenu2());
              final showFactory = tutorialState.step
                  .isAfterOrEqual(const TutorialStep.openBuildMenu());
              final showSatellites = tutorialState.step
                  .isAfterOrEqual(const TutorialStep.businessBuilt());
              final showDestroyMode = tutorialState.step
                  .isAfterOrEqual(const TutorialStep.hidden());

              return Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText('Build here',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                          Flexible(
                            child: AppText('Choose an option  →',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: <Widget>[
                          if (showFactory)
                            BuildPanelItem(
                              emoji: '🏭',
                              title: 'Factory',
                              description: 'Produces resources.',
                              details:
                                  'Choose a resource after building. The factory produces it over time; use Doggie Express to move it to your warehouse, then from the warehouse to a market. Production has a recurring fee.',
                              canBuild: canBuildFactory,
                              isBusy: isBuilding.value,
                              onPressed: () => submit(
                                BuildPanelEvent.buildFactory(
                                    pinMarkerState.location),
                                'sounds/cash_register.mp3',
                                location: currencyLocation,
                                price: factoryPrice,
                                tutorial: const TutorialEvent.factoryPlace(),
                              ),
                              price: factoryPrice,
                            ),
                          if (showStorage)
                            BuildPanelItem(
                              emoji: '⛺️',
                              title: 'Warehouse',
                              description: 'Stores your resources.',
                              details:
                                  'Receive resources from factories with Doggie Express and keep them here for later use.',
                              canBuild: canBuildStorage,
                              isBusy: isBuilding.value,
                              onPressed: () => submit(
                                BuildPanelEvent.buildStorage(
                                    pinMarkerState.location),
                                'sounds/cash_register.mp3',
                                location: currencyLocation,
                                price: storagePrice,
                                tutorial: const TutorialEvent.storagePlace(),
                              ),
                              price: storagePrice,
                            ),
                          if (showBusiness)
                            BuildPanelItem(
                              emoji: '🏢',
                              title: 'Business',
                              description: 'Generates income over time.',
                              details:
                                  'Earn money over time. Collect income directly from the business or use a nearby satellite to collect from several businesses.',
                              canBuild: canBuildBusiness,
                              isBusy: isBuilding.value,
                              onPressed: () => submit(
                                BuildPanelEvent.buildBusiness(
                                    pinMarkerState.location),
                                'sounds/cash_register.mp3',
                                location: currencyLocation,
                                price: businessPrice,
                                tutorial: const TutorialEvent.businessPlace(),
                              ),
                              price: businessPrice,
                            ),
                          if (showSatellites)
                            BuildPanelItem(
                              emoji: '🗼',
                              title: 'Satellite · 1',
                              description: 'Collects business income.',
                              details:
                                  'Collect income from your businesses within ${config.satelliteRadius[0]} map cells.',
                              canBuild: canBuildSatellite1,
                              isBusy: isBuilding.value,
                              onPressed: () => submit(
                                BuildPanelEvent.buildSatellite(
                                    pinMarkerState.location, 1),
                                'sounds/satellite_build.mp3',
                                location: currencyLocation,
                                price: satellite1Price,
                              ),
                              price: satellite1Price,
                            ),
                          if (showSatellites)
                            BuildPanelItem(
                              emoji: '🛰',
                              title: 'Satellite · 2',
                              description: 'Connects level 1 satellites.',
                              details:
                                  'Collect through your level 1 satellites within ${config.satelliteRadius[1]} map cells. Each level 1 satellite collects income from nearby businesses.',
                              canBuild: canBuildSatellite2,
                              isBusy: isBuilding.value,
                              onPressed: () => submit(
                                BuildPanelEvent.buildSatellite(
                                    pinMarkerState.location, 2),
                                'sounds/satellite_build.mp3',
                                location: currencyLocation,
                                price: satellite2Price,
                              ),
                              price: satellite2Price,
                            ),
                          if (showSatellites)
                            BuildPanelItem(
                              emoji: '📡',
                              title: 'Satellite · 3',
                              description: 'Connects level 2 satellites.',
                              details:
                                  'Collect through your level 2 satellites within ${config.satelliteRadius[2]} map cells. They connect to level 1 satellites, which collect business income.',
                              canBuild: canBuildSatellite3,
                              isBusy: isBuilding.value,
                              onPressed: () => submit(
                                BuildPanelEvent.buildSatellite(
                                    pinMarkerState.location, 3),
                                'sounds/satellite_build.mp3',
                                location: currencyLocation,
                                price: satellite3Price,
                              ),
                              price: satellite3Price,
                            ),
                          if (showDestroyMode)
                            BuildPanelItem(
                              emoji: '🔧',
                              title: 'Demolish',
                              isDemolition: true,
                              description: 'Remove a building.',
                              details:
                                  'Enter demolition mode, then select a building on the map. You will be asked to confirm before it is removed.',
                              canBuild: true,
                              onPressed: () {
                                panelController.close();
                                _showBuildingList(context, user.id, config);
                              },
                              price: 0,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

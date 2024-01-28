import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/map/build_mode/build_mode_bloc.dart';
import 'package:package_flutter/bloc/map/build_panel/build_panel_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:package_flutter/presentation/map/build_panel_item.dart';
import 'package:separated_row/separated_row.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BuildPanel extends HookConsumerWidget {
  final PanelController panelController;

  BuildPanel({super.key, required this.panelController});

  final _buyAudioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;
    final config = ref.watch(configProvider).value!;
    final money = user.money;

    return MultiBlocListener(
      listeners: [
        BlocListener<BuildPanelBloc, BuildPanelState>(
          listener: (context, state) {
            state.maybeMap(
              loadFailure: (s) => context
                  .read<NotificationsBloc>()
                  .add(NotificationsEvent.warningAdded(s.failure.getMessage())),
              orElse: () {},
            );
          },
        ),
      ],
      child: BlocBuilder<PinMarkerBloc, PinMarkerState>(
        builder: (context, pinMarkerState) {
          final boosters = ref.read(activatedBoostersProvider.notifier);
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
                  top: 32 + MediaQuery.of(context).padding.top,
                  bottom: 27,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SeparatedRow(
                      includeOuterSeparators: true,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 20),
                      children: <Widget>[
                        if (showFactory)
                          BuildPanelItem(
                            emoji: '🏭',
                            canBuild: canBuildFactory,
                            onPressed: () {
                              _buyAudioPlayer.play(
                                AssetSource('sounds/cash_register.mp3'),
                              );
                              context.read<BuildPanelBloc>().add(
                                    BuildPanelEvent.buildFactory(
                                      pinMarkerState.location,
                                    ),
                                  );
                              context
                                  .read<TutorialBloc>()
                                  .add(const TutorialEvent.factoryPlace());
                              panelController.close();
                            },
                            price: factoryPrice,
                          ),
                        if (showStorage)
                          BuildPanelItem(
                            emoji: '⛺️',
                            canBuild: canBuildStorage,
                            onPressed: () {
                              _buyAudioPlayer.play(
                                AssetSource('sounds/cash_register.mp3'),
                              );
                              context.read<BuildPanelBloc>().add(
                                    BuildPanelEvent.buildStorage(
                                      pinMarkerState.location,
                                    ),
                                  );
                              context
                                  .read<TutorialBloc>()
                                  .add(const TutorialEvent.storagePlace());
                              panelController.close();
                            },
                            price: storagePrice,
                          ),
                        if (showBusiness)
                          BuildPanelItem(
                            emoji: '🏢',
                            canBuild: canBuildBusiness,
                            onPressed: () {
                              _buyAudioPlayer.play(
                                AssetSource('sounds/cash_register.mp3'),
                              );
                              context.read<BuildPanelBloc>().add(
                                    BuildPanelEvent.buildBusiness(
                                      pinMarkerState.location,
                                    ),
                                  );
                              context
                                  .read<TutorialBloc>()
                                  .add(const TutorialEvent.businessPlace());
                              panelController.close();
                            },
                            price: businessPrice,
                          ),
                        if (showSatellites)
                          BuildPanelItem(
                            emoji: '🗼',
                            canBuild: canBuildSatellite1,
                            onPressed: () {
                              _buyAudioPlayer.play(
                                AssetSource('sounds/satellite_build.mp3'),
                              );
                              context.read<BuildPanelBloc>().add(
                                    BuildPanelEvent.buildSatellite(
                                      pinMarkerState.location,
                                      1,
                                    ),
                                  );
                              panelController.close();
                            },
                            price: satellite1Price,
                          ),
                        if (showSatellites)
                          BuildPanelItem(
                            emoji: '🛰',
                            canBuild: canBuildSatellite2,
                            onPressed: () {
                              _buyAudioPlayer.play(
                                AssetSource('sounds/satellite_build.mp3'),
                              );
                              context.read<BuildPanelBloc>().add(
                                    BuildPanelEvent.buildSatellite(
                                      pinMarkerState.location,
                                      2,
                                    ),
                                  );
                              panelController.close();
                            },
                            price: satellite2Price,
                          ),
                        if (showSatellites)
                          BuildPanelItem(
                            emoji: '📡',
                            canBuild: canBuildSatellite3,
                            onPressed: () {
                              _buyAudioPlayer.play(
                                AssetSource('sounds/satellite_build.mp3'),
                              );
                              context.read<BuildPanelBloc>().add(
                                    BuildPanelEvent.buildSatellite(
                                      pinMarkerState.location,
                                      3,
                                    ),
                                  );
                              panelController.close();
                            },
                            price: satellite3Price,
                          ),
                        if (showDestroyMode)
                          BuildPanelItem(
                            emoji: '🔧',
                            canBuild: true,
                            onPressed: () {
                              context.read<BuildModeBloc>().add(
                                    const BuildModeEvent.enteredDestroyMode(),
                                  );
                              panelController.close();
                            },
                            price: 0,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

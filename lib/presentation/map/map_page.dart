import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/building/building_bloc.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/bloc/map/build_panel/build_panel_bloc.dart';
import 'package:package_flutter/bloc/map/map_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/presentation/core/root/sfx_volume.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';
import 'package:package_flutter/presentation/inventory/inventory.dart';
import 'package:package_flutter/presentation/map/boosters_column.dart';
import 'package:package_flutter/presentation/map/build_panel.dart';
import 'package:package_flutter/presentation/map/destroy_mode_menu.dart';
import 'package:package_flutter/presentation/map/map_widget.dart';
import 'package:package_flutter/presentation/sidebar/sidebar.dart';
import 'package:package_flutter/presentation/tutorial/dialogue_window.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _buildPanelController = PanelController();
  final _inventoryPanelController = PanelController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentBottomSheetController? destroyModeController;

  final _sidebar = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PinMarkerBloc()),
        BlocProvider(create: (context) => MapBloc()),
        BlocProvider(
          create: (context) =>
              BuildPanelBloc(ref.watch(buildingRepositoryProvider)),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<BuildingBloc, BuildingState>(
            listener: (context, state) {
              if (state.failureOrNull != null) {
                context.read<NotificationsBloc>().add(
                      NotificationsEvent.warningAdded(
                        state.failureOrNull!.getMessage(),
                      ),
                    );
              }
            },
          ),
        ],
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: BlocBuilder<EmojiBloc, EmojiState>(
            builder: (context, emojiState) {
              final emojis = emojiState.maybeMap(
                loadSuccess: (e) => e.emojis,
                orElse: () => throw const UnexpectedValueError(),
              );
              return BlocBuilder<GeolocationBloc, GeolocationState>(
                builder: (context, geoState) {
                  final geolocation = geoState.maybeMap(
                    loadSuccess: (geoState) => LatLng(
                      geoState.position.latitude,
                      geoState.position.longitude,
                    ),
                    orElse: () => LatLng(0, 0),
                  );

                  return BlocListener<PinMarkerBloc, PinMarkerState>(
                    listener: (context, state) async {
                      if (state.isShown) {
                        _buildPanelController.open();

                        final player = AudioPlayer();
                        await player.setVolume(
                          ref.read(sfxVolumeProvider),
                        );
                        player.play(AssetSource('sounds/pin_placed.wav'));
                      }
                    },
                    child: ShowCaseWidget(
                      enableAutoScroll: true,
                      disableBarrierInteraction: true,
                      builder: Builder(
                        builder: (context) {
                          return BlocListener<TutorialBloc, TutorialState>(
                            listener: (context, tutorialState) {
                              tutorialState.step.maybeMap(
                                openDoggyExpress: (_) =>
                                    ShowCaseWidget.of(context)
                                        .startShowCase([_sidebar]),
                                openFMMarket: (_) => ShowCaseWidget.of(context)
                                    .startShowCase([_sidebar]),
                                orElse: () {},
                              );
                            },
                            child: Scaffold(
                              key: scaffoldKey,
                              drawer: const Sidebar(),
                              body: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  SlidingUpPanel(
                                    controller: _buildPanelController,
                                    slideDirection: SlideDirection.DOWN,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    panel: BuildPanel(
                                      panelController: _buildPanelController,
                                    ),
                                    minHeight: 0,
                                    maxHeight: 185 +
                                        MediaQuery.of(context).padding.top,
                                    onPanelClosed: () => context
                                        .read<PinMarkerBloc>()
                                        .add(
                                          const PinMarkerEvent.markerHidden(),
                                        ),
                                    onPanelOpened: () {
                                      context.read<TutorialBloc>().add(
                                            const TutorialEvent
                                                .buildMenuOpened(),
                                          );
                                    },
                                    backdropEnabled: true,
                                    body: SlidingUpPanel(
                                      controller: _inventoryPanelController,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(37),
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      maxHeight:
                                          MediaQuery.of(context).size.height -
                                              162,
                                      panel: const Inventory(),
                                      backdropEnabled: true,
                                      // TODO(P5ina): Add sound
                                      onPanelOpened: () {
                                        context.read<TutorialBloc>().add(
                                              const TutorialEvent
                                                  .inventoryOpened(),
                                            );
                                      },
                                      body: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          MapWidget(
                                            geolocation: geolocation,
                                            emojis: emojis,
                                            user: user,
                                          ),
                                          Positioned(
                                            top: MediaQuery.of(context)
                                                .padding
                                                .top,
                                            left: 10,
                                            child: Column(
                                              children: [
                                                Showcase(
                                                  key: _sidebar,
                                                  description: 'Open sidebar',
                                                  disposeOnTap: true,
                                                  onTargetClick: () =>
                                                      scaffoldKey.currentState!
                                                          .openDrawer(),
                                                  child: IconButton(
                                                    onPressed: () => scaffoldKey
                                                        .currentState!
                                                        .openDrawer(),
                                                    iconSize: 45,
                                                    color:
                                                        const Color(0xFF979797),
                                                    icon:
                                                        const Icon(Icons.menu),
                                                  ),
                                                ),
                                                const BoostersColumn(),
                                              ],
                                            ),
                                          ),
                                          BlocBuilder<TutorialBloc,
                                              TutorialState>(
                                            builder: (context, tutorialState) =>
                                                tutorialState.step.maybeMap(
                                              orElse: () =>
                                                  const DialogueWindow(),
                                              hidden: (_) => Container(),
                                              hidden2: (_) => Container(),
                                            ),
                                          ),
                                          BlocBuilder<TutorialBloc,
                                              TutorialState>(
                                            builder: (
                                              context,
                                              tutorialState,
                                            ) =>
                                                tutorialState.step.maybeMap(
                                              initial: (_) => Container(),
                                              hidden: (_) => Container(),
                                              hidden2: (_) => Container(),
                                              businessBuilt: (_) => Container(),
                                              ending: (_) => Container(),
                                              orElse: () =>
                                                  const SkipTutorialButton(),
                                            ),
                                          ),
                                          const CurrencyUpdateText(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const DestroyModeMenu(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class SkipTutorialButton extends StatelessWidget {
  const SkipTutorialButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 50,
        ),
        child: ElevatedButton(
          onPressed: () {
            context.read<TutorialBloc>().add(
                  const TutorialEvent.skip(),
                );
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
          ),
          child: const Text(
            'skip tutorial',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencyUpdateText extends ConsumerStatefulWidget {
  const CurrencyUpdateText({
    super.key,
  });

  @override
  ConsumerState<CurrencyUpdateText> createState() => _CurrencyUpdateTextState();
}

class _CurrencyUpdateTextState extends ConsumerState<CurrencyUpdateText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> positionAnimation;
  late Animation<double> opacityAnimation;

  BigInt? previousMoney;
  BigInt? previousGems;
  BigInt? previousExp;
  BigInt moneyDiff = BigInt.from(0);
  BigInt gemsDiff = BigInt.from(0);
  BigInt expDiff = BigInt.from(0);

  @override
  void initState() {
    super.initState();
    previousMoney = ref.read(userProvider).value!.money;
    previousExp = ref.read(userProvider).value!.experience;
    previousGems = ref.read(userProvider).value!.gems;
    controller =
        AnimationController(duration: const Duration(seconds: 7), vsync: this);
    positionAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.15, curve: Curves.easeOutCubic),
    );
    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.05, 0.2, curve: Curves.fastOutSlowIn),
    );
    opacityAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.9, 1, curve: Curves.fastOutSlowIn),
    );
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final positionTween =
        Tween<double>(begin: -40, end: MediaQuery.of(context).padding.top);
    final scaleTween = Tween<double>(begin: 20, end: 32);
    final opacityTween = Tween<double>(begin: 1, end: 0);

    // TODO(P5ina): remove previous values
    ref.listen<AsyncValue<User>>(userProvider, (previous, next) {
      final user = next.value!;
      if (previousMoney != user.money) {
        controller.forward(from: 0);
      }
      if (previousExp != user.experience) {
        controller.forward(from: 0);
      }
      if (previousGems != user.gems) {
        controller.forward(from: 0);
      }
      setState(() {
        gemsDiff = user.gems - (previousGems ?? user.gems);
        moneyDiff = user.money - (previousMoney ?? user.money);
        expDiff = user.experience - (previousExp ?? user.experience);
        previousMoney = user.money;
        previousExp = user.experience;
        previousGems = user.gems;
      });
    });

    final updates = <String>[];
    if (moneyDiff > BigInt.from(0)) {
      updates.add('+${moneyDiff.toCurrency()} 💵');
    } else if (moneyDiff < BigInt.from(0)) {
      updates.add('${moneyDiff.toCurrency()} 💵');
    }

    if (gemsDiff > BigInt.from(0)) {
      updates.add('+${gemsDiff.toCurrency()} 💎');
    } else if (expDiff < BigInt.from(0)) {
      updates.add('${gemsDiff.toCurrency()} 💎');
    }

    if (expDiff > BigInt.from(0)) {
      updates.add('+${expDiff.toCurrency()} 🎖️');
    } else if (expDiff < BigInt.from(0)) {
      updates.add('${expDiff.toCurrency()} 🎖️');
    }

    final text = updates.join(' ');
    return Positioned(
      top: positionTween.evaluate(positionAnimation),
      child: Opacity(
        opacity: opacityTween.evaluate(opacityAnimation),
        child: Text(
          text,
          style: TextStyle(
            fontSize: scaleTween.evaluate(scaleAnimation),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

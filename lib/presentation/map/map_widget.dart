import 'package:audioplayers/audioplayers.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geohex/geohex.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/building/building_bloc.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/map/build_mode/build_mode_bloc.dart';
import 'package:package_flutter/bloc/map/map_bloc.dart';
import 'package:package_flutter/bloc/map/map_bounds_provider.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/bloc/satellite/satellite_bloc.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/bloc/user/users_in_bounds_provider.dart';
import 'package:package_flutter/data/latlng/lat_lng_extension.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:package_flutter/domain/emoji/emoji.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/domain/user/user_on_map.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:package_flutter/presentation/business/business_menu.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';
import 'package:package_flutter/presentation/core/currency_change.dart';
import 'package:package_flutter/presentation/core/root/map_dark_mode.dart';
import 'package:package_flutter/presentation/core/root/sfx_volume.dart';
import 'package:package_flutter/presentation/factory/factory_menu.dart';
import 'package:package_flutter/presentation/map/business_marker.dart';
import 'package:package_flutter/presentation/map/destory_dialog.dart';
import 'package:package_flutter/presentation/map/factory_marker.dart';
import 'package:package_flutter/presentation/map/map_currency_change.dart';
import 'package:package_flutter/presentation/map/pin_marker.dart';
import 'package:package_flutter/presentation/map/storage_marker.dart';
import 'package:package_flutter/presentation/map/truck_markers.dart';
import 'package:package_flutter/presentation/map/building_menu_frame.dart';
import 'package:package_flutter/presentation/market/market_menu.dart';
import 'package:package_flutter/presentation/satellite/satellite_menu.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({
    super.key,
    required this.geolocation,
    required this.emojis,
    required this.user,
    required this.currencyChange,
  });

  final LatLng geolocation;
  final List<Emoji> emojis;
  final User user;
  final MapCurrencyChange? currencyChange;

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _linesAnimationController;
  late AnimationController _cameraAnimationController;
  late MapController _mapController;
  VoidCallback? _cameraMoveListener;
  final _mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _linesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<TruckBloc>().add(const TruckEvent.listenTrucksRequested());
    }
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currencyChange = widget.currencyChange;
    if (currencyChange != null &&
        currencyChange.id != oldWidget.currencyChange?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCurrencyChange(currencyChange);
      });
    }
  }

  void _showCurrencyChange(MapCurrencyChange currencyChange) {
    final mapRenderObject = _mapKey.currentContext?.findRenderObject();
    if (mapRenderObject is! RenderBox) return;
    final mapPosition =
        _mapController.camera.latLngToScreenOffset(currencyChange.location);
    final globalPosition = mapRenderObject.localToGlobal(
      mapPosition - const Offset(0, 32),
    );
    showCurrencyChangeAtGlobalPosition(
      context,
      currencyChange.amount,
      globalPosition,
    );
  }

  @override
  void dispose() {
    _cameraAnimationController.dispose();
    _linesAnimationController.dispose();
    _mapController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersInBounds = ref.watch(usersInBoundsProvider);
    final user = ref.watch(userProvider).value!;

    // print(Env.getMapDarkUrl());

    ref.listen<AsyncValue<List<UserOnMap>>>(usersInBoundsProvider,
        (previous, next) {
      next.when(
        data: (_) {},
        error: (e, st) {
          Logger().e("Can't get users in bounds!", error: e, stackTrace: st);
        },
        loading: () {},
      );
    });

    final config = ref.watch(configProvider).value!;

    return BlocBuilder<PinMarkerBloc, PinMarkerState>(
      builder: (context, pinMarkerState) {
        return BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            switch (state) {
              case MapStateIdle():
                break;
              case MapStateMoveToPlayer():
                final mapLatitudeTween = Tween<double>(
                  begin: _mapController.camera.center.latitude,
                  end: widget.geolocation.latitude,
                );
                final mapLongitudeTween = Tween<double>(
                  begin: _mapController.camera.center.longitude,
                  end: widget.geolocation.longitude,
                );
                final mapZoomTween = Tween<double>(
                  begin: _mapController.camera.zoom,
                  end: 15.5,
                );
                final mapRotationTween = Tween<double>(
                  begin: _mapController.camera.rotation,
                  end: 0,
                );

                final Animation<double> animation = CurvedAnimation(
                  parent: _cameraAnimationController,
                  curve: Curves.fastOutSlowIn,
                );

                if (_cameraMoveListener != null) {
                  _cameraAnimationController
                      .removeListener(_cameraMoveListener!);
                }
                _cameraMoveListener = () => _mapController.moveAndRotate(
                      LatLng(
                        mapLatitudeTween.evaluate(animation),
                        mapLongitudeTween.evaluate(animation),
                      ),
                      mapZoomTween.evaluate(animation),
                      mapRotationTween.evaluate(animation),
                    );
                _cameraAnimationController.addListener(_cameraMoveListener!);

                _cameraAnimationController.forward(from: 0);
            }
          },
          child: BlocBuilder<BuildModeBloc, BuildModeState>(
            builder: (context, buildModeState) {
              return Builder(
                builder: (context) {
                  return BlocBuilder<BuildingBloc, BuildingState>(
                    builder: (context, buildingState) {
                      return BlocConsumer<SatelliteBloc, SatelliteState>(
                        listener: (context, satelliteState) async {
                          switch (satelliteState) {
                            case SatelliteStateInitial():
                              break;
                            case SatelliteStateLoading():
                              break;
                            case SatelliteStateShowLines():
                              context.read<BuildingBloc>().add(
                                    BuildingEvent.updatedBounds(
                                      _mapController.camera.visibleBounds,
                                    ),
                                  );
                              final player = AudioPlayer();
                              await player.setVolume(
                                ref.read(sfxVolumeProvider),
                              );
                              player.play(
                                AssetSource(
                                  'sounds/radar.wav',
                                ),
                              );
                              _linesAnimationController.forward(from: 0);
                          }
                        },
                        builder: (context, satelliteState) {
                          return FlutterMap(
                            key: _mapKey,
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: widget.geolocation,
                              initialZoom: 16,
                              minZoom: 15,
                              maxZoom: 18,
                              interactionOptions: InteractionOptions(
                                flags: InteractiveFlag.all &
                                    ~InteractiveFlag.doubleTapZoom &
                                    ~InteractiveFlag.rotate,
                              ),
                              backgroundColor: const Color(0xFF0f1014),
                              onMapReady: () {
                                context.read<BuildingBloc>().add(
                                      BuildingEvent.updatedBounds(
                                        _mapController.camera.visibleBounds,
                                      ),
                                    );
                                ref.read(mapBoundsProvider.notifier).setBounds(
                                    _mapController.camera.visibleBounds);
                              },
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture) {
                                  _cameraAnimationController.stop();
                                }
                                context.read<BuildingBloc>().add(
                                      BuildingEvent.updatedBounds(
                                        position.visibleBounds,
                                      ),
                                    );
                                ref.read(mapBoundsProvider.notifier).setBounds(
                                    _mapController.camera.visibleBounds);
                              },
                              onTap: (event, location) {
                                if (buildModeState
                                    is BuildModeStateDestroyMode) {
                                  return;
                                }
                                if (location
                                        .calculateDistance(widget.geolocation) >
                                    config.interactionRadiusKm) {
                                  context.read<NotificationsBloc>().add(
                                        const NotificationsEvent.warningAdded(
                                          'Choose a location closer to you.',
                                        ),
                                      );
                                  return;
                                }
                                context.read<PinMarkerBloc>().add(
                                      PinMarkerEvent.placed(
                                        location,
                                        widget.geolocation,
                                        config.interactionRadiusKm.toDouble(),
                                        config,
                                      ),
                                    );
                              },
                            ),
                            children: [
                              TileLayer(
                                userAgentPackageName:
                                    'com.TriangleInteractive.Package',
                                urlTemplate: ref.watch(mapDarkModeProvider)
                                    ? Env.getMapDarkUrl()
                                    : Env.getMapWhiteUrl(),
                                tileBuilder: ref.watch(mapDarkModeProvider) &&
                                        Env.getMapDarkUrl() ==
                                            Env.getMapWhiteUrl()
                                    ? darkModeTileBuilder
                                    : null,
                                additionalOptions: {
                                  'api_key': Env.getMapAccessKey(),
                                },
                                retinaMode: RetinaMode.isHighDensity(context),
                                tileProvider: CachedTileProvider(),
                              ),
                              const SimpleAttributionWidget(
                                source: Text('OpenStreetMap contributors'),
                              ),
                              PolylineLayer(
                                polylines: <Polyline>[
                                  ...switch (satelliteState) {
                                    SatelliteStateInitial() => [],
                                    SatelliteStateLoading() => [],
                                    SatelliteStateShowLines(
                                      :final linesAndHexes
                                    ) =>
                                      linesAndHexes.lines.map((l) {
                                        final endCurve = CurvedAnimation(
                                          parent: _linesAnimationController,
                                          curve: const Interval(
                                            0,
                                            0.5,
                                            curve: Curves.ease,
                                          ),
                                        );
                                        final startCurve = CurvedAnimation(
                                          parent: _linesAnimationController,
                                          curve: const Interval(
                                            0.5,
                                            1,
                                            curve: Curves.ease,
                                          ),
                                        );
                                        final latEndAnim = Tween<double>(
                                          begin: l.start.latitude,
                                          end: l.end.latitude,
                                        ).animate(endCurve);
                                        final lngEndAnim = Tween<double>(
                                          begin: l.start.longitude,
                                          end: l.end.longitude,
                                        ).animate(endCurve);
                                        final latStartAnim = Tween<double>(
                                          begin: l.start.latitude,
                                          end: l.end.latitude,
                                        ).animate(startCurve);
                                        final lngStartAnim = Tween<double>(
                                          begin: l.start.longitude,
                                          end: l.end.longitude,
                                        ).animate(startCurve);

                                        return Polyline(
                                          points: [
                                            LatLng(
                                              latStartAnim.value,
                                              lngStartAnim.value,
                                            ),
                                            LatLng(
                                              latEndAnim.value,
                                              lngEndAnim.value,
                                            ),
                                          ],
                                          color: Theme.of(context).primaryColor,
                                          strokeWidth: 2,
                                        );
                                      }).toList(),
                                  },
                                ],
                              ),
                              PolygonLayer(
                                polygons: <Polygon>[
                                  ...switch (satelliteState) {
                                    SatelliteStateInitial() => [],
                                    SatelliteStateLoading() => [],
                                    SatelliteStateShowLines(
                                      :final linesAndHexes
                                    ) =>
                                      [
                                        ...linesAndHexes.firstLayer.map((h) {
                                          final curve = CurvedAnimation(
                                            parent: _linesAnimationController,
                                            curve: const Interval(
                                              0.5,
                                              0.7,
                                              curve: Curves.easeInQuad,
                                            ),
                                          );

                                          final firstLayerOpacity =
                                              TweenSequence(
                                            <TweenSequenceItem<double>>[
                                              TweenSequenceItem(
                                                tween: Tween<double>(
                                                  begin: 0,
                                                  end: 1,
                                                ),
                                                weight: 50,
                                              ),
                                              TweenSequenceItem(
                                                tween: Tween<double>(
                                                  begin: 1,
                                                  end: 0,
                                                ),
                                                weight: 50,
                                              ),
                                            ],
                                          ).animate(curve);

                                          return Polygon(
                                            points: h.hexCoords!
                                                .map(
                                                  (c) => LatLng(c.lat, c.lon),
                                                )
                                                .toList(),
                                            color: const Color(0xFFFFB800)
                                                .withValues(
                                              alpha: firstLayerOpacity.value,
                                            ),
                                          );
                                        }),
                                        ...linesAndHexes.secondLayer.map((h) {
                                          final curve = CurvedAnimation(
                                            parent: _linesAnimationController,
                                            curve: const Interval(
                                              0.7,
                                              0.9,
                                            ),
                                          );

                                          final secondLayerOpacity =
                                              TweenSequence(
                                            <TweenSequenceItem<double>>[
                                              TweenSequenceItem(
                                                tween: Tween<double>(
                                                  begin: 0,
                                                  end: 1,
                                                ),
                                                weight: 50,
                                              ),
                                              TweenSequenceItem(
                                                tween: Tween<double>(
                                                  begin: 1,
                                                  end: 0,
                                                ),
                                                weight: 50,
                                              ),
                                            ],
                                          ).animate(curve);

                                          return Polygon(
                                            points: h.hexCoords!
                                                .map(
                                                  (c) => LatLng(c.lat, c.lon),
                                                )
                                                .toList(),
                                            color: const Color(0xFFFFB800)
                                                .withValues(
                                              alpha: secondLayerOpacity.value,
                                            ),
                                          );
                                        }),
                                      ],
                                  },
                                  if (pinMarkerState.isShown)
                                    Polygon(
                                      points: pinMarkerState.cell.hexCoords!
                                          .map((e) => LatLng(e.lat, e.lon))
                                          .toList(),
                                      color: const Color.fromARGB(
                                        128,
                                        71,
                                        71,
                                        71,
                                      ),
                                    ),
                                ],
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    radius:
                                        config.interactionRadiusKm.toDouble(),
                                    point: widget.geolocation,
                                    color: const Color(0x30FFB800),
                                    useRadiusInMeter: true,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  ...?usersInBounds.valueOrNull?.map((u) {
                                    final geohash = GeoHash(u.geohash);

                                    return Marker(
                                      point: LatLng(
                                        geohash.latitude(),
                                        geohash.longitude(),
                                      ),
                                      alignment: Alignment.center,
                                      child: Builder(
                                        builder: (context) {
                                          final avatarId =
                                              config.avatars.indexOf(u.avatar);
                                          return Image.asset(
                                            'assets/images/avatars/$avatarId.png',
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                  ...buildingState.buildings.map((b) {
                                    final geohex = Zone.byCode(b.geohex);

                                    final iconName = switch (b) {
                                      BusinessBuilding() => () {
                                          final level = (b.level ~/ 5) * 5;
                                          final hours = DateTime.now()
                                              .difference(b.updatedAt)
                                              .inHours;
                                          var stage = 'stage1';
                                          if (hours >= 1) {
                                            stage = 'stage2';
                                          }
                                          if (hours >= 6) {
                                            stage = 'stage3';
                                          }
                                          if (hours >= 12) {
                                            stage = 'stage4';
                                          }
                                          final enemyOrFriend =
                                              b.ownerId == user.id
                                                  ? 'friend'
                                                  : 'enemy';
                                          final businessKey =
                                              'business${level}_${stage}_$enemyOrFriend';
                                          return businessKey;
                                        }(),
                                      StorageBuilding() => b.ownerId == user.id
                                          ? 'storage_friend'
                                          : 'storage_enemy',
                                      FactoryBuilding() => b.ownerId == user.id
                                          ? 'factory_friend'
                                          : 'factory_enemy',
                                      MarketBuilding() => 'market_${b.level}',
                                      SatelliteBuilding() =>
                                        b.ownerId == user.id
                                            ? 'satellite${b.level}_friend'
                                            : 'satellite${b.level}_enemy',
                                    };

                                    final size = switch (b) {
                                      FactoryBuilding() => 55.0,
                                      _ => 50.0,
                                    };

                                    final opacity = switch (buildModeState) {
                                      BuildModeStateBuildMode() => 1.0,
                                      BuildModeStateDestroyMode() => switch (
                                            b) {
                                          BusinessBuilding() =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                          StorageBuilding() =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                          FactoryBuilding() =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                          MarketBuilding() => 0.5,
                                          SatelliteBuilding() =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                        },
                                    };
                                    return Marker(
                                      width: size,
                                      height: size,
                                      point: LatLng(geohex.lat, geohex.lon),
                                      child: Builder(
                                        builder: (ctx) => Opacity(
                                          opacity: opacity,
                                          child: GestureDetector(
                                            onTap: switch (buildModeState) {
                                              BuildModeStateBuildMode() => () =>
                                                  _openBuildingMenu(
                                                    context,
                                                    b,
                                                    user,
                                                  ),
                                              BuildModeStateDestroyMode() =>
                                                () {
                                                  if (opacity < 1.0) {
                                                    return;
                                                  }
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        DestroyDialog(
                                                      building: b,
                                                    ),
                                                  );
                                                },
                                            },
                                            child: switch (b) {
                                              StorageBuilding() =>
                                                StorageMarker(
                                                  iconName: iconName,
                                                  storage: b,
                                                ),
                                              FactoryBuilding() =>
                                                FactoryMarker(b),
                                              BusinessBuilding() =>
                                                BusinessMarker(iconName, b),
                                              _ => Image.asset(
                                                  'assets/images/buildings/$iconName.png',
                                                )
                                            },
                                          ),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                    );
                                  }),
                                  // User marker
                                  Marker(
                                    point: widget.geolocation,
                                    alignment: Alignment.center,
                                    child: Builder(builder: (context) {
                                      final avatarId =
                                          config.avatars.indexOf(user.avatar);
                                      return Image.asset(
                                        'assets/images/avatars/$avatarId.png',
                                      );
                                    }),
                                  ),
                                  // Pin marker (Build marker)
                                  if (pinMarkerState.isShown)
                                    Marker(
                                      point: pinMarkerState.location,
                                      alignment: Alignment.topCenter,
                                      child: const PinMarker(),
                                    ),
                                ],
                              ),
                              TruckMarkers(
                                ownerId: widget.user.id,
                                arrivedUpdates: ref
                                    .read(socketRepositoryProvider)
                                    .getTruckArrivedUpdates(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openBuildingMenu(
    BuildContext context,
    Building building,
    User user,
  ) async {
    final isOwner = switch (building) {
      BusinessBuilding(:final ownerId) => ownerId == user.id,
      StorageBuilding(:final ownerId) => ownerId == user.id,
      FactoryBuilding(:final ownerId) => ownerId == user.id,
      MarketBuilding() => false,
      SatelliteBuilding(:final ownerId) => ownerId == user.id,
    };

    final details = switch (building) {
      BusinessBuilding(:final id) when isOwner => BusinessMenu(id),
      StorageBuilding() when isOwner => const Padding(
          padding: EdgeInsets.all(24),
          child: AppText(
            'Receive resources from factories with Doggie Express and keep them here for later use.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ),
      FactoryBuilding(:final id) when isOwner => FactoryMenu(factoryId: id),
      MarketBuilding(:final id) => MarketMenu(marketId: id),
      SatelliteBuilding() when isOwner => SatelliteMenu(building),
      _ => null,
    };

    final sound = switch (building) {
      BusinessBuilding() => 'sounds/business_click.wav',
      FactoryBuilding() => 'sounds/factory_click.wav',
      MarketBuilding() => 'sounds/market_click.wav',
      StorageBuilding() || SatelliteBuilding() => null,
    };
    if (sound != null) {
      final player = AudioPlayer();
      await player.setVolume(ref.read(sfxVolumeProvider));
      await player.play(AssetSource(sound));
    }

    if (!context.mounted) return;
    await showBuildingMenuSheet(
      context: context,
      building: building,
      currentUser: user,
      buildingEmoji: building.getEmoji(ref.read(configProvider).value!),
      details: details,
    );
  }
}

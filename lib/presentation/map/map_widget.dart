import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geohex/geohex.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/building/building_bloc.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/map/build_mode/build_mode_bloc.dart';
import 'package:package_flutter/bloc/map/map_bloc.dart';
import 'package:package_flutter/bloc/map/map_bounds_provider.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/bloc/satellite/satellite_bloc.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/bloc/user/users_in_bounds_provider.dart';
import 'package:package_flutter/data/latlng/lat_lng_extension.dart';
import 'package:package_flutter/domain/core/env_provider.dart';
import 'package:package_flutter/domain/emoji/emoji.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/domain/user/user_on_map.dart';
import 'package:package_flutter/presentation/business/business_menu.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';
import 'package:package_flutter/presentation/core/root/map_dark_mode.dart';
import 'package:package_flutter/presentation/core/root/sfx_volume.dart';
import 'package:package_flutter/presentation/factory/factory_menu.dart';
import 'package:package_flutter/presentation/map/business_marker.dart';
import 'package:package_flutter/presentation/map/destory_dialog.dart';
import 'package:package_flutter/presentation/map/factory_marker.dart';
import 'package:package_flutter/presentation/map/pin_marker.dart';
import 'package:package_flutter/presentation/map/storage_marker.dart';
import 'package:package_flutter/presentation/market/market_menu.dart';
import 'package:package_flutter/presentation/satellite/satellite_menu.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({
    super.key,
    required this.geolocation,
    required this.emojis,
    required this.user,
  });

  final LatLng geolocation;
  final List<Emoji> emojis;
  final User user;

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Timer? timer;
  late AnimationController _linesAnimationController;
  late AnimationController _cameraAnimationController;
  late MapController _mapController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _linesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {});
    });
    _linesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<TruckBloc>().add(const TruckEvent.listenTrucksRequested());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersInBounds = ref.watch(usersInBoundsProvider);
    final user = ref.watch(userProvider).value!;

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
            state.map(
              idle: (s) {},
              moveToPlayer: (s) async {
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

                _cameraAnimationController.addListener(
                  () => _mapController.moveAndRotate(
                    LatLng(
                      mapLatitudeTween.evaluate(animation),
                      mapLongitudeTween.evaluate(animation),
                    ),
                    mapZoomTween.evaluate(animation),
                    mapRotationTween.evaluate(animation),
                  ),
                );

                _cameraAnimationController.forward(from: 0);
              },
            );
          },
          child: BlocBuilder<BuildModeBloc, BuildModeState>(
            builder: (context, buildModeState) {
              return BlocBuilder<TruckBloc, TruckState>(
                builder: (context, truckState) {
                  return BlocBuilder<BuildingBloc, BuildingState>(
                    builder: (context, buildingState) {
                      return BlocConsumer<SatelliteBloc, SatelliteState>(
                        listener: (context, satelliteState) {
                          satelliteState.map(
                            initial: (_) {},
                            loading: (_) {},
                            showLines: (s) async {
                              context.read<BuildingBloc>().add(
                                    BuildingEvent.updatedBounds(
                                      _mapController.bounds!,
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
                            },
                          );
                        },
                        builder: (context, satelliteState) {
                          return FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: widget.geolocation,
                              zoom: 16,
                              minZoom: 15,
                              maxZoom: 18,
                              interactiveFlags: InteractiveFlag.all &
                                  ~InteractiveFlag.doubleTapZoom &
                                  ~InteractiveFlag.rotate,
                              onMapReady: () {
                                context.read<BuildingBloc>().add(
                                      BuildingEvent.updatedBounds(
                                        _mapController.bounds!,
                                      ),
                                    );
                                ref
                                    .read(mapBoundsProvider.notifier)
                                    .setBounds(_mapController.bounds!);
                              },
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture) {
                                  _cameraAnimationController.stop();
                                }
                                context.read<BuildingBloc>().add(
                                      BuildingEvent.updatedBounds(
                                        position.bounds!,
                                      ),
                                    );
                                ref
                                    .read(mapBoundsProvider.notifier)
                                    .setBounds(_mapController.bounds!);
                              },
                              onTap: (event, location) {
                                context.read<PinMarkerBloc>().add(
                                      PinMarkerEvent.markerPlaced(
                                        location,
                                        widget.geolocation,
                                        config.interactionRadiusKm.toDouble(),
                                        config,
                                      ),
                                    );
                              },
                            ),
                            nonRotatedChildren: [],
                            children: [
                              TileLayer(
                                urlTemplate: ref.watch(mapDarkModeProvider)
                                    ? ref.watch(envProvider).mapDarkUrl
                                    : ref.watch(envProvider).mapWhiteUrl,
                                additionalOptions: {
                                  'api_key':
                                      ref.watch(envProvider).mapAccessKey,
                                },
                                backgroundColor: const Color(0xFF0f1014),
                                tileProvider: CachedTileProvider(),
                              ),
                              PolylineLayer(
                                polylines: [
                                  ...satelliteState.map(
                                    initial: (_) => [],
                                    loading: (_) => [],
                                    showLines: (s) {
                                      return s.linesAndHexes.lines.map((l) {
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
                                      }).toSet();
                                    },
                                  ),
                                ],
                              ),
                              PolygonLayer(
                                polygons: [
                                  ...satelliteState.map(
                                    initial: (_) => [],
                                    loading: (_) => [],
                                    showLines: (s) => [
                                      ...s.linesAndHexes.firstLayer.map((h) {
                                        final curve = CurvedAnimation(
                                          parent: _linesAnimationController,
                                          curve: const Interval(
                                            0.5,
                                            0.7,
                                            curve: Curves.easeInQuad,
                                          ),
                                        );

                                        final firstLayerOpacity = TweenSequence(
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
                                          isFilled: true,
                                          points: h.hexCoords!
                                              .map(
                                                (c) => LatLng(c.lat, c.lon),
                                              )
                                              .toList(),
                                          color: const Color(0xFFFFB800)
                                              .withOpacity(
                                            firstLayerOpacity.value,
                                          ),
                                        );
                                      }),
                                      ...s.linesAndHexes.secondLayer.map((h) {
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
                                          isFilled: true,
                                          points: h.hexCoords!
                                              .map(
                                                (c) => LatLng(c.lat, c.lon),
                                              )
                                              .toList(),
                                          color: const Color(0xFFFFB800)
                                              .withOpacity(
                                            secondLayerOpacity.value,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  if (pinMarkerState.isShown)
                                    Polygon(
                                      isFilled: true,
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
                                    color: const Color.fromARGB(
                                      128,
                                      71,
                                      71,
                                      71,
                                    ),
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
                                      anchorPos:
                                          AnchorPos.align(AnchorAlign.center),
                                      builder: (context) {
                                        final avatarId =
                                            config.avatars.indexOf(u.avatar);
                                        return Image.asset(
                                          'assets/images/avatars/$avatarId.png',
                                        );
                                      },
                                    );
                                  }),
                                  ...buildingState.buildings.map((b) {
                                    final geohex = Zone.byCode(b.geohex);

                                    final iconName = b.map(
                                      business: (b) {
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
                                      },
                                      storage: (b) => b.ownerId == user.id
                                          ? 'storage_friend'
                                          : 'storage_enemy',
                                      factory: (b) => b.ownerId == user.id
                                          ? 'factory_friend'
                                          : 'factory_enemy',
                                      market: (b) => 'market_${b.level}',
                                      satellite: (b) => b.ownerId == user.id
                                          ? 'satellite${b.level}_friend'
                                          : 'satellite${b.level}_enemy',
                                    );

                                    final opacity = buildModeState.map(
                                      buildMode: (s) => 1.0,
                                      destroyMode: (s) => b.map(
                                        business: (b) =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                        storage: (b) =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                        factory: (b) =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                        market: (b) => 0.5,
                                        satellite: (b) =>
                                            b.ownerId == user.id ? 1.0 : 0.5,
                                      ),
                                    );

                                    final size = b.maybeMap(
                                      factory: (_) => 55.0,
                                      orElse: () => 50.0,
                                    );

                                    return Marker(
                                      width: size,
                                      height: size,
                                      point: LatLng(geohex.lat, geohex.lon),
                                      builder: (ctx) => Opacity(
                                        opacity: opacity,
                                        child: GestureDetector(
                                          onTap: () => buildModeState.map(
                                            buildMode: (_) => b.map(
                                              business: (b) async {
                                                showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) =>
                                                      BusinessMenu(b.id),
                                                );
                                                final player = AudioPlayer();
                                                await player.setVolume(
                                                  ref.read(
                                                    sfxVolumeProvider,
                                                  ),
                                                );
                                                player.play(
                                                  AssetSource(
                                                    'sounds/business_click.wav',
                                                  ),
                                                );
                                                return null;
                                              },
                                              storage: (_) {
                                                return null;
                                              },
                                              satellite: (b) {
                                                if (b.ownerId != user.id) {
                                                  return;
                                                }

                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      SatelliteMenu(b),
                                                );
                                                return null;
                                              },
                                              factory: (b) async {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      FactoryMenu(
                                                    factoryId: b.id,
                                                  ),
                                                );
                                                final player = AudioPlayer();
                                                await player.setVolume(
                                                  ref.read(
                                                    sfxVolumeProvider,
                                                  ),
                                                );
                                                player.play(
                                                  AssetSource(
                                                    'sounds/factory_click.wav',
                                                  ),
                                                );
                                                return null;
                                              },
                                              market: (b) async {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      MarketMenu(
                                                    marketId: b.id,
                                                  ),
                                                );

                                                final player = AudioPlayer();
                                                await player.setVolume(
                                                  ref.read(
                                                    sfxVolumeProvider,
                                                  ),
                                                );
                                                AudioPlayer().play(
                                                  AssetSource(
                                                    'sounds/market_click.wav',
                                                  ),
                                                );
                                                return null;
                                              },
                                            ),
                                            destroyMode: (_) {
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
                                              return null;
                                            },
                                          ),
                                          child: b.maybeMap(
                                            storage: (s) => StorageMarker(
                                              iconName: iconName,
                                              storage: s,
                                            ),
                                            factory: (f) => FactoryMarker(f),
                                            business: (b) =>
                                                BusinessMarker(iconName, b),
                                            orElse: () {
                                              return Image.asset(
                                                'assets/images/buildings/$iconName.png',
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      anchorPos: AnchorPos.align(
                                        AnchorAlign.center,
                                      ),
                                    );
                                  }),
                                  // User marker
                                  Marker(
                                    point: widget.geolocation,
                                    anchorPos:
                                        AnchorPos.align(AnchorAlign.center),
                                    builder: (context) {
                                      final avatarId =
                                          config.avatars.indexOf(user.avatar);
                                      return Image.asset(
                                        'assets/images/avatars/$avatarId.png',
                                      );
                                    },
                                  ),
                                  ...truckState.map(
                                    initial: (_) => [],
                                    loadInProgress: (_) => [],
                                    loadFailure: (_) => [],
                                    loadSuccess: (s) => s.trucks
                                        .map((t) => truckMarker(user, t)),
                                  ),
                                  // Pin marker (Build marker)
                                  if (pinMarkerState.isShown)
                                    Marker(
                                      point: pinMarkerState.location,
                                      alignment: Alignment.topCenter,
                                      child: const PinMarker(),
                                    ),
                                ],
                              )
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

  Marker truckMarker(
    User user,
    Truck truck,
  ) {
    final points = decodePolyline(truck.path, accuracyExponent: 6)
        .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
        .toList();

    if (truck.endTime.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      Logger().d('Removing truck ${truck.id} from map');
      if (truck.ownerId == user.id) {
        context.read<TutorialBloc>().add(const TutorialEvent.truckArrived());
      }
      context.read<TruckBloc>().add(TruckEvent.truckArrived(truck));
    }

    return Marker(
      point: interpolatePath(truck.startTime, truck.endTime, points),
      child: Image.asset('assets/images/trucks/truck${truck.truckType}.png'),
    );
  }

  LatLng interpolatePath(DateTime start, DateTime end, List<LatLng> points) {
    final fullDuration = end.difference(start);
    final elapsed = DateTime.now().difference(start);
    final percent = elapsed.inMilliseconds / fullDuration.inMilliseconds;

    final fullDistance = getFullDistance(points);
    final distanceNow = fullDistance * percent.clamp(0, 1);

    var currentWaypoint = 0;
    var prevLength = 0.0;
    var dist =
        points[currentWaypoint].calculateDistance(points[currentWaypoint + 1]);
    while (distanceNow > prevLength + dist) {
      prevLength += dist;
      currentWaypoint++;
      dist = points[currentWaypoint]
          .calculateDistance(points[currentWaypoint + 1]);
    }

    return lerp(
      points[currentWaypoint],
      points[currentWaypoint + 1],
      (distanceNow - prevLength) / dist,
    );
  }

  double getFullDistance(List<LatLng> points) {
    double distanceTotal = 0;
    for (var i = 0; i < points.length - 1; i++) {
      distanceTotal += points[i].calculateDistance(points[i + 1]);
    }
    return distanceTotal;
  }

  LatLng lerp(LatLng a, LatLng b, double t) {
    final tClamped = t.clamp(0, 1);
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * tClamped,
      a.longitude + (b.longitude - a.longitude) * tClamped,
    );
  }
}

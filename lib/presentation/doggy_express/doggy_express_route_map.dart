import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geohex/geohex.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/doggie_express/delivery_buildings/delivery_buildings_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/sidebar/map_dark_mode_provider.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/env_provider.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';
import 'package:package_flutter/presentation/map/business_marker.dart';
import 'package:package_flutter/presentation/map/factory_marker.dart';
import 'package:package_flutter/presentation/map/storage_marker.dart';
import 'package:package_flutter/presentation/market/market_loading.dart';

class DoggyExpressRouteMap extends ConsumerStatefulWidget {
  const DoggyExpressRouteMap({
    super.key,
  });

  @override
  ConsumerState<DoggyExpressRouteMap> createState() =>
      _DoggyExpressRouteMapState();
}

class _DoggyExpressRouteMapState extends ConsumerState<DoggyExpressRouteMap> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryBuildingsBloc, DeliveryBuildingsState>(
      listener: (context, state) {
        state.mapOrNull(
          loadFailure: (state) => context.read<NotificationsBloc>().add(
                NotificationsEvent.warningAdded(
                  state.f.getMessage(),
                ),
              ),
        );
      },
      builder: (context, deliveryBuildingsState) {
        final user = ref.watch(userProvider).value!;

        return BlocBuilder<TutorialBloc, TutorialState>(
          builder: (context, tutorialState) {
            return BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
              builder: (context, doggieExpressState) {
                final isFirstSelected = doggieExpressState.pointA != null;
                final isSecondSelected = doggieExpressState.pointB != null;

                // COORDINATES
                final pointAZone = isFirstSelected
                    ? Zone.byCode(doggieExpressState.pointA!.geohex)
                    : Zone.byLocation(0, 0, 7);
                final pointBZone = isSecondSelected
                    ? Zone.byCode(doggieExpressState.pointB!.geohex)
                    : Zone.byLocation(0, 0, 7);

                // Showing only suitable markets
                // int marketGroupWhitelist = 0;
                // if (isFirstSelected &&
                //     doggieExpressState.pointA is FactoryBuilding) {
                //   marketGroupWhitelist = config.items
                //       .whereType<ItemResource>()
                //       .firstWhere(
                //         (i) =>
                //             i.name ==
                //             (doggieExpressState.pointA!
                //                     as FactoryBuilding)
                //                 .currentResource,
                //         orElse: () => config.items
                //             .whereType<ItemResource>()
                //             .first,
                //       )
                //       .group;
                // }

                final buildings = deliveryBuildingsState.maybeMap(
                  loadSuccess: (state) => isFirstSelected
                      ? isSecondSelected
                          ? [
                              doggieExpressState.pointA!,
                              doggieExpressState.pointB!
                            ]
                          : state.buildings.destinations
                              .where(
                                (b) => b.id != doggieExpressState.pointA?.id,
                              )
                              .where((b) {
                                if (doggieExpressState.pointA!
                                        is FactoryBuilding &&
                                    b is MarketBuilding) {
                                  return false;
                                }
                                if (doggieExpressState.pointA!
                                        is MarketBuilding &&
                                    b is MarketBuilding) {
                                  return false;
                                }
                                return true;
                              })
                              .where(
                                (b) => tutorialState.step.maybeMap(
                                  orElse: () => true,
                                  openDoggyExpress: (_) => b is StorageBuilding,
                                  openDoggyExpress2: (_) => b is MarketBuilding,
                                ),
                              )
                              .toList()
                      : isSecondSelected
                          ? state.buildings.starts
                              .where(
                                (b) => b.id != doggieExpressState.pointB?.id,
                              )
                              .where((b) {
                                if (doggieExpressState.pointB!
                                        is MarketBuilding &&
                                    b is MarketBuilding) {
                                  return false;
                                }
                                if (doggieExpressState.pointB!
                                        is MarketBuilding &&
                                    b is FactoryBuilding) {
                                  return false;
                                }
                                return true;
                              })
                              .where(
                                (b) => tutorialState.step.maybeMap(
                                  orElse: () => true,
                                  openDoggyExpress: (_) => b is FactoryBuilding,
                                  openDoggyExpress2: (_) =>
                                      b is FactoryBuilding ||
                                      b is StorageBuilding,
                                ),
                              )
                              .toList()
                          : state.buildings.starts,
                  orElse: () => <Building>[],
                );

                return BlocBuilder<GeolocationBloc, GeolocationState>(
                  builder: (context, geoState) {
                    return geoState.map(
                      initial: (_) => const MarketLoading(),
                      loadFailure: (_) => const MarketLoading(),
                      loadInProgress: (_) => const MarketLoading(),
                      loadSuccess: (geoState) => Expanded(
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                              geoState.position.latitude,
                              geoState.position.longitude,
                            ),
                            maxZoom: 18,
                            interactiveFlags: InteractiveFlag.all &
                                ~InteractiveFlag.doubleTapZoom &
                                ~InteractiveFlag.rotate,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: ref.watch(mapDarkModeProvider)
                                  ? ref.watch(envProvider).mapDarkUrl
                                  : ref.watch(envProvider).mapWhiteUrl,
                              additionalOptions: {
                                'api_key': ref.watch(envProvider).mapAccessKey,
                              },
                              backgroundColor: const Color(0xFF0f1014),
                              tileProvider: CachedTileProvider(),
                            ),
                            PolylineLayer(
                              polylines: [
                                if (isFirstSelected && isSecondSelected)
                                  Polyline(
                                    points: [
                                      LatLng(pointAZone.lat, pointAZone.lon),
                                      LatLng(pointBZone.lat, pointBZone.lon),
                                    ],
                                    color: const Color(0xFFFFB800),
                                    strokeWidth: 3,
                                    isDotted: true,
                                  ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                ...buildings.map((b) {
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
                                      final enemyOrFriend = b.ownerId == user.id
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

                                  final size = b.maybeMap(
                                    factory: (_) => 55.0,
                                    orElse: () => 50.0,
                                  );

                                  return Marker(
                                    width: size,
                                    height: size,
                                    point: LatLng(geohex.lat, geohex.lon),
                                    builder: (context) => GestureDetector(
                                      onTap: () {
                                        isFirstSelected
                                            ? isSecondSelected
                                                ? () {}
                                                : context
                                                    .read<DoggieExpressBloc>()
                                                    .add(
                                                      DoggieExpressEvent
                                                          .pointBSelected(b),
                                                    )
                                            : context
                                                .read<DoggieExpressBloc>()
                                                .add(
                                                  DoggieExpressEvent
                                                      .pointASelected(
                                                    b,
                                                  ),
                                                );
                                      },
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
                                    anchorPos:
                                        AnchorPos.align(AnchorAlign.center),
                                  );
                                }),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

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
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';
import 'package:package_flutter/presentation/core/root/map_dark_mode.dart';
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
        switch (state) {
          case DeliveryBuildingsStateLoadFailure(:final f):
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.warningAdded(
                    f.getMessage(),
                  ),
                );
          default:
            break;
        }
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

                final buildings = switch (deliveryBuildingsState) {
                  DeliveryBuildingsStateLoadSuccess(:final buildings) =>
                    isFirstSelected
                        ? isSecondSelected
                            ? [
                                doggieExpressState.pointA!,
                                doggieExpressState.pointB!
                              ]
                            : buildings.destinations
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
                                  (b) => switch (tutorialState.step) {
                                    OpenDoggyExpress() => b is StorageBuilding,
                                    OpenDoggyExpress2() => b is MarketBuilding,
                                    _ => true,
                                  },
                                )
                                .toList()
                        : isSecondSelected
                            ? buildings.starts
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
                                  (b) => switch (tutorialState.step) {
                                    OpenDoggyExpress() => b is FactoryBuilding,
                                    OpenDoggyExpress2() =>
                                      b is FactoryBuilding ||
                                          b is StorageBuilding,
                                    _ => true,
                                  },
                                )
                                .toList()
                            : buildings.starts,
                  DeliveryBuildingsStateLoadFailure() => <Building>[],
                  DeliveryBuildingsStateLoadInProgress() => <Building>[],
                  DeliveryBuildingsStateInitial() => <Building>[],
                };

                return BlocBuilder<GeolocationBloc, GeolocationState>(
                  builder: (context, geoState) {
                    return switch (geoState) {
                      GeolocationStateInitial() => const MarketLoading(),
                      GeolocationStateLoadFailure() => const MarketLoading(),
                      GeolocationStateLoadInProgress() => const MarketLoading(),
                      GeolocationStateLoadSuccess() => Expanded(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                geoState.position.latitude,
                                geoState.position.longitude,
                              ),
                              backgroundColor: const Color(0xFF0f1014),
                              maxZoom: 18,
                              interactionOptions: InteractionOptions(
                                flags: InteractiveFlag.all &
                                    ~InteractiveFlag.doubleTapZoom &
                                    ~InteractiveFlag.rotate,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: ref.watch(mapDarkModeProvider)
                                    ? Env.getMapDarkUrl()
                                    : Env.getMapWhiteUrl(),
                                additionalOptions: {
                                  'api_key': Env.getMapAccessKey(),
                                },
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
                                      pattern: StrokePattern.dotted(),
                                    ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  ...buildings.map((b) {
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

                                    return Marker(
                                      width: size,
                                      height: size,
                                      point: LatLng(geohex.lat, geohex.lon),
                                      child: GestureDetector(
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
                                        child: switch (b) {
                                          StorageBuilding() => StorageMarker(
                                              iconName: iconName,
                                              storage: b,
                                            ),
                                          FactoryBuilding() => FactoryMarker(b),
                                          BusinessBuilding() =>
                                            BusinessMarker(iconName, b),
                                          _ => Image.asset(
                                              'assets/images/buildings/$iconName.png',
                                            ),
                                        },
                                      ),
                                      alignment: Alignment.center,
                                    );
                                  }),
                                ],
                              )
                            ],
                          ),
                        ),
                    };
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

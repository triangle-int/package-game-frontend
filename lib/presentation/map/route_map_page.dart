import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/truck/remove_schedule.dart/remove_schedule_bloc.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/data/latlng/lat_lng_extension.dart';
import 'package:package_flutter/domain/core/env_provider.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_schedule.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/root/map_dark_mode.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';

@RoutePage()
class RouteMapPage extends ConsumerStatefulWidget {
  const RouteMapPage({super.key, required this.truckOrSchedule});

  final Either<Truck, TruckSchedule> truckOrSchedule;

  @override
  ConsumerState<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends ConsumerState<RouteMapPage> {
  late MapController _mapController;
  bool _isConfirm = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {});
    });
    _mapController = MapController();
    context.read<RemoveScheduleBloc>().add(const RemoveScheduleEvent.reset());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = decodePolyline(
      widget.truckOrSchedule.fold(
        (truck) => truck.path,
        (schedule) => schedule.lastPath,
      ),
      accuracyExponent: 6,
    ).map((p) => LatLng(p[0].toDouble(), p[1].toDouble())).toList();
    // final latMax = path.reduce((value, element) => value.latitude < element.latitude ? element : value).latitude;
    // final latMin = path.reduce((value, element) => value.latitude > element.latitude ? element : value).latitude;
    // final lngMax = path.reduce((value, element) => value.longitude < element.longitude ? element : value).longitude;
    // final lngMin = path.reduce((value, element) => value.longitude > element.longitude ? element : value).longitude;

    return BlocConsumer<RemoveScheduleBloc, RemoveScheduleState>(
      listener: (context, removeScheduleState) {
        switch (removeScheduleState) {
          case RemoveScheduleStateLoadSuccess():
            context.router.pop();
          case RemoveScheduleStateLoadFailure(:final failure):
            context
                .read<NotificationsBloc>()
                .add(NotificationsEvent.warningAdded(failure.getMessage()));
          default:
            break;
        }
      },
      builder: (context, removeScheduleState) {
        return BlocBuilder<TruckBloc, TruckState>(
          builder: (context, truckState) {
            return Scaffold(
              body: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      interactionOptions: InteractionOptions(
                        enableMultiFingerGestureRace: true,
                      ),
                      backgroundColor: const Color(0xFF0f1014),
                      onMapReady: () {
                        _mapController.fitCamera(
                          CameraFit.bounds(
                            bounds: LatLngBounds.fromPoints(path),
                            padding: const EdgeInsets.all(40),
                          ),
                        );
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: ref.watch(mapDarkModeProvider)
                            ? ref.watch(envProvider).mapDarkUrl
                            : ref.watch(envProvider).mapWhiteUrl,
                        additionalOptions: {
                          'api_key': ref.watch(envProvider).mapAccessKey,
                        },
                        tileProvider: CachedTileProvider(),
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: path,
                            strokeWidth: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          ...switch (truckState) {
                            TruckStateInitial() => [],
                            TruckStateLoadInProgress() => [],
                            TruckStateLoadFailure() => [],
                            TruckStateLoadSuccess(:final trucks) => trucks
                                .where(
                                  (t) => widget.truckOrSchedule.fold(
                                    (t2) => t.id == t2.id,
                                    (schedule) => schedule.id == t.scheduleId,
                                  ),
                                )
                                .map((t) => truckMarker(context, t)),
                          },
                        ],
                      )
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(37),
                        ),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: () => context.router.pop(),
                          icon: const EmojiImage(emoji: '❌'),
                        ),
                      ),
                    ),
                  ),
                  if (widget.truckOrSchedule.isRight())
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 28,
                      width: 247,
                      height: 49,
                      child: switch (removeScheduleState) {
                        RemoveScheduleStateInitial() => removeButton(context),
                        RemoveScheduleStateLoadInProgress() => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        RemoveScheduleStateLoadFailure() =>
                          removeButton(context),
                        RemoveScheduleStateLoadSuccess() => Container(),
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ElevatedButton removeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_isConfirm) {
          context.read<RemoveScheduleBloc>().add(
                RemoveScheduleEvent.remove(
                  widget.truckOrSchedule.fold(
                    (t) => throw const UnexpectedValueError(),
                    (s) => s.id,
                  ),
                ),
              );
        } else {
          setState(() {
            _isConfirm = true;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(37),
        ),
        backgroundColor: _isConfirm
            ? const Color(0xFFE53D1F)
            : Theme.of(context).primaryColor,
        foregroundColor: _isConfirm ? Colors.white : Colors.black,
      ),
      child: Text(
        _isConfirm ? 'CONFIRM' : 'DESTROY',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Marker truckMarker(
    BuildContext context,
    Truck truck,
  ) {
    final points = decodePolyline(truck.path)
        .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
        .toList();

    if (truck.endTime.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      widget.truckOrSchedule.fold((t) => context.router.pop(), (sch) {});
    }

    return Marker(
      point: interpolatePath(truck.startTime, truck.endTime, points),
      rotate: true,
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

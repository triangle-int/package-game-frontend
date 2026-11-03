import 'package:package_flutter/l10n/app_text.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/truck/remove_schedule.dart/remove_schedule_bloc.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_schedule.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/root/map_dark_mode.dart';
import 'package:package_flutter/presentation/core/unexpected_value_error.dart';
import 'package:package_flutter/presentation/map/truck_path.dart';

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
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = decodeTruckPath(
      widget.truckOrSchedule.fold(
        (truck) => truck.path,
        (schedule) => schedule.lastPath,
      ),
    );

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
                  if (path.isEmpty)
                    const Center(child: AppText('Route is unavailable'))
                  else
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        interactionOptions: InteractionOptions(
                          enableMultiFingerGestureRace: true,
                        ),
                        backgroundColor: const Color(0xFF0f1014),
                        initialCenter: path.first,
                        onMapReady: () {
                          if (path.length < 2) return;
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
                          userAgentPackageName:
                              'com.TriangleInteractive.Package',
                          urlTemplate: ref.watch(mapDarkModeProvider)
                              ? Env.getMapDarkUrl()
                              : Env.getMapWhiteUrl(),
                          tileBuilder: ref.watch(mapDarkModeProvider) &&
                                  Env.getMapDarkUrl() == Env.getMapWhiteUrl()
                              ? darkModeTileBuilder
                              : null,
                          additionalOptions: {
                            'api_key': Env.getMapAccessKey(),
                          },
                          tileProvider: CachedTileProvider(),
                        ),
                        const SimpleAttributionWidget(
                          source: Text('OpenStreetMap contributors'),
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
                                  .map(truckMarker)
                                  .whereType<Marker>(),
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
                        color: Theme.of(context).colorScheme.surface,
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
      child: AppText(
        _isConfirm ? 'Confirm cancellation' : 'Cancel schedule',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Marker? truckMarker(Truck truck) {
    final position = truckPosition(
      decodeTruckPath(truck.path),
      truck.startTime,
      truck.endTime,
      DateTime.now(),
    );
    if (position == null) return null;
    return Marker(
      point: position,
      rotate: true,
      child: Image.asset('assets/images/trucks/truck${truck.truckType}.png'),
    );
  }
}

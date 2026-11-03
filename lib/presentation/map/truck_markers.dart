import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/presentation/map/truck_path.dart';

/// Animates all active deliveries on the main map, including other players'.
class TruckMarkers extends StatefulWidget {
  const TruckMarkers({
    super.key,
    required this.ownerId,
    this.clock,
    this.arrivedUpdates,
  });

  final int ownerId;
  final DateTime Function()? clock;
  final Stream<Map<String, dynamic>>? arrivedUpdates;

  @override
  State<TruckMarkers> createState() => _TruckMarkersState();
}

class _TruckMarkersState extends State<TruckMarkers> {
  final _paths = <String, List<LatLng>>{};
  final _arrivedTruckIds = <int>{};
  var _previousTrucks = <Truck>[];
  late final Timer _timer;
  StreamSubscription<Map<String, dynamic>>? _arrivedSubscription;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<TruckBloc>().state;
    if (initialState is TruckStateLoadSuccess) {
      _previousTrucks = initialState.trucks;
    }
    _arrivedSubscription = widget.arrivedUpdates?.listen((data) {
      if (!mounted) return;
      if (data['ownerId'] == widget.ownerId &&
          _arrivedTruckIds.add(data['id'] as int)) {
        context.read<TutorialBloc>().add(const TutorialEvent.truckArrived());
      }
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final state = context.read<TruckBloc>().state;
      if (state is! TruckStateLoadSuccess || state.trucks.isEmpty) return;
      final now = widget.clock?.call() ?? DateTime.now();
      for (final truck in state.trucks) {
        if (!truck.endTime.isAfter(now) && _arrivedTruckIds.add(truck.id)) {
          if (truck.ownerId == widget.ownerId) {
            context
                .read<TutorialBloc>()
                .add(const TutorialEvent.truckArrived());
          }
          context.read<TruckBloc>().add(TruckEvent.truckArrived(truck));
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _arrivedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TruckBloc, TruckState>(
      listener: (context, state) {
        if (state is! TruckStateLoadSuccess) return;
        final activeIds = state.trucks.map((truck) => truck.id).toSet();
        final now = widget.clock?.call() ?? DateTime.now();
        for (final truck in _previousTrucks) {
          if (!activeIds.contains(truck.id) &&
              truck.ownerId == widget.ownerId &&
              truck.endTime.difference(now) <= const Duration(seconds: 5) &&
              _arrivedTruckIds.add(truck.id)) {
            context
                .read<TutorialBloc>()
                .add(const TutorialEvent.truckArrived());
          }
        }
        _arrivedTruckIds.retainAll(activeIds);
        _previousTrucks = state.trucks;
      },
      builder: (context, state) {
        if (state is! TruckStateLoadSuccess) {
          return const MarkerLayer(markers: []);
        }
        final trucks = state.trucks;
        final activePaths = trucks.map((truck) => truck.path).toSet();
        _paths.removeWhere((path, _) => !activePaths.contains(path));
        final now = widget.clock?.call() ?? DateTime.now();
        return MarkerLayer(
          markers: [
            for (final truck in trucks)
              if (truck.endTime.isAfter(now))
                if (truckPosition(
                  _paths.putIfAbsent(
                    truck.path,
                    () => decodeTruckPath(truck.path),
                  ),
                  truck.startTime,
                  truck.endTime,
                  now,
                )
                    case final position?)
                  Marker(
                    point: position,
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/trucks/truck${truck.truckType}.png',
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_shipping),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

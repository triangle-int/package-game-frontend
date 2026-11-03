import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class TruckOnLine extends StatefulWidget {
  const TruckOnLine(
    this.truck, {
    super.key,
  });

  final Truck truck;

  @override
  State<TruckOnLine> createState() => _TruckOnLineState();
}

class _TruckOnLineState extends State<TruckOnLine> {
  Timer? _timer;
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (!widget.truck.endTime.isAfter(now) &&
          (_lastRefresh == null ||
              now.difference(_lastRefresh!) >= const Duration(seconds: 10))) {
        _lastRefresh = now;
        context.read<SidebarBloc>().add(const SidebarEvent.routesSelected());
      }

      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant TruckOnLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.truck.id != widget.truck.id ||
        oldWidget.truck.endTime != widget.truck.endTime) {
      _lastRefresh = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const truckEmojis = [
      '🦮',
      '🚚',
      '🛩',
    ];
    final truckType = widget.truck.truckType;
    final truckEmoji = truckType >= 0 && truckType < truckEmojis.length
        ? truckEmojis[truckType]
        : '🚚';

    final diff = widget.truck.endTime.difference(widget.truck.startTime);
    final ratio = diff.inMilliseconds <= 0
        ? 1.0
        : (DateTime.now().difference(widget.truck.startTime).inMilliseconds /
                diff.inMilliseconds)
            .clamp(0.0, 1.0);

    return Align(
      alignment: Alignment((ratio * 2) - 1, 0),
      child: EmojiImage(emoji: truckEmoji, size: 18),
    );
  }
}

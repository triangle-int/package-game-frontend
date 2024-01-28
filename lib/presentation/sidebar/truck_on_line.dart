import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
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

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (widget.truck.endTime.isBefore(DateTime.now())) {
        Logger().w('RELOAD TRUCKS');
        context.read<SidebarBloc>().add(const SidebarEvent.routesSelected());
      }

      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final truckEmoji = [
      '🦮',
      '🚚',
      '🛩',
    ][widget.truck.truckType];

    final diff = widget.truck.endTime.difference(widget.truck.startTime);
    final ratio =
        DateTime.now().difference(widget.truck.startTime).inMilliseconds /
            diff.inMilliseconds;

    return Align(
      alignment: Alignment((ratio * -2) + 1, 0),
      child: EmojiImage(emoji: truckEmoji, size: 18),
    );
  }
}

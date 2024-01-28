import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/domain/truck/truck_schedule.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/sidebar/truck_on_line.dart';

class ScheduleItem extends StatefulHookConsumerWidget {
  const ScheduleItem(
    this.schedule, {
    super.key,
  });

  final TruckSchedule schedule;

  @override
  ConsumerState<ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends ConsumerState<ScheduleItem> {
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.schedule.nextTime.isBefore(DateTime.now())) {
        Logger().w('RELOAD SCHEDULES');
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
    final interval = [
      '1h',
      '6h',
      '12h',
    ][widget.schedule.interval];

    final untilNext = widget.schedule.nextTime.difference(DateTime.now()).abs();
    final untilNextString = untilNext.inHours > 0
        ? '${untilNext.inHours}h ${untilNext.inMinutes % 60}m'
        : untilNext.inMinutes > 0
            ? '${untilNext.inMinutes}m ${untilNext.inSeconds % 60}s'
            : '${untilNext.inSeconds}s';

    final config = ref.watch(configProvider).value!;

    final emojiResource = config.items
        .firstWhere((i) => i.name == widget.schedule.resource)
        .emoji;
    final resourceCount = widget.schedule.resourceCount.toCurrency();

    final emojiStart = widget.schedule.start.getEmoji(config);
    final emojiDestination = widget.schedule.destination.getEmoji(config);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$interval route\n$untilNextString till next\ncargo: $resourceCount $emojiResource',
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () => context.router.push(
                    RouteMapRoute(
                      truckOrSchedule: dartz.right(widget.schedule),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(48, 48),
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.all(3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const EmojiImage(emoji: '📍'),
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            EmojiImage(emoji: emojiStart, size: 24),
            Expanded(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ...widget.schedule.trucks.map((t) => TruckOnLine(t))
                    ],
                  ),
                  Container(
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF979797),
                    ),
                  ),
                ],
              ),
            ),
            EmojiImage(emoji: emojiDestination, size: 24),
          ],
        )
      ],
    );
  }
}

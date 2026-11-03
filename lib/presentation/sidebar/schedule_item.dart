import 'package:package_flutter/l10n/translations.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/bloc/truck/remove_schedule.dart/remove_schedule_bloc.dart';
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
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (!widget.schedule.nextTime.isAfter(now) &&
          (_lastRefresh == null ||
              now.difference(_lastRefresh!) >= const Duration(seconds: 10))) {
        _lastRefresh = now;
        context.read<SidebarBloc>().add(const SidebarEvent.routesSelected());
      }

      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant ScheduleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule.id != widget.schedule.id ||
        oldWidget.schedule.nextTime != widget.schedule.nextTime) {
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
    const intervals = [
      '1h',
      '6h',
      '12h',
    ];
    final intervalIndex = widget.schedule.interval;
    final interval = intervalIndex >= 0 && intervalIndex < intervals.length
        ? intervals[intervalIndex]
        : 'Scheduled';

    final remaining = widget.schedule.nextTime.difference(DateTime.now());
    final untilNext = remaining.isNegative ? Duration.zero : remaining;
    final untilNextString = untilNext.inHours > 0
        ? '${untilNext.inHours}h ${untilNext.inMinutes % 60}m'
        : untilNext.inMinutes > 0
            ? '${untilNext.inMinutes}m ${untilNext.inSeconds % 60}s'
            : '${untilNext.inSeconds}s';

    final config = ref.watch(configProvider).value!;

    final resources =
        config.items.where((i) => i.name == widget.schedule.resource);
    final emojiResource = resources.isEmpty ? '📦' : resources.first.emoji;
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
                AppText(
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
                child: BlocBuilder<RemoveScheduleBloc, RemoveScheduleState>(
                  builder: (context, state) => IconButton(
                    tooltip: translate(context, 'Cancel schedule'),
                    onPressed: state is RemoveScheduleStateLoadInProgress
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const AppText('Cancel schedule?'),
                                content: const AppText(
                                  'Future deliveries on this schedule will stop.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const AppText('Keep schedule'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const AppText('Cancel schedule'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              context.read<RemoveScheduleBloc>().add(
                                    RemoveScheduleEvent.remove(
                                        widget.schedule.id),
                                  );
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
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

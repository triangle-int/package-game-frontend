import 'package:package_flutter/l10n/app_text.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/sidebar/truck_on_line.dart';

class TruckItem extends StatefulHookConsumerWidget {
  const TruckItem(
    this.truck, {
    super.key,
  });

  final Truck truck;

  @override
  ConsumerState<TruckItem> createState() => _TruckItemState();
}

class _TruckItemState extends ConsumerState<TruckItem> {
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
  void didUpdateWidget(covariant TruckItem oldWidget) {
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
    final remaining = widget.truck.endTime.difference(DateTime.now());
    final untilNext = remaining.isNegative ? Duration.zero : remaining;
    final untilNextString = untilNext.inHours > 0
        ? '${untilNext.inHours}h ${untilNext.inMinutes % 60}m'
        : untilNext.inMinutes > 0
            ? '${untilNext.inMinutes}m ${untilNext.inSeconds % 60}s'
            : '${untilNext.inSeconds}s';

    final config = ref.watch(configProvider).value!;

    final resources =
        config.items.where((i) => i.name == widget.truck.resource);
    final emojiResource = resources.isEmpty ? '📦' : resources.first.emoji;
    final resourceCount = widget.truck.resourceCount.toCurrency();

    final emojiStart = widget.truck.startBuilding?.getEmoji(config) ?? '📍';
    final emojiDestination =
        widget.truck.destinationBuilding?.getEmoji(config) ?? '📍';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'one time route\n$untilNextString away\ncargo: $resourceCount $emojiResource',
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.3,
                  ),
                ),
              ],
            ),
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
                      TruckOnLine(widget.truck),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/booster/activated_boosters_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/booster/booster.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/state_national_marketplace/help_dialog.dart';
import 'package:separated_column/separated_column.dart';

class BoostersColumn extends StatefulHookConsumerWidget {
  const BoostersColumn({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => BoostersColumnState();
}

class BoostersColumnState extends ConsumerState<ConsumerStatefulWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Booster>>>(
      activatedBoostersProvider,
      (previous, next) {
        next.when(
          data: (_) {},
          error: (e, st) => Logger().e("Can't load activated boosters", e, st),
          loading: () {},
        );
      },
    );

    final config = ref.watch(configProvider).asData!.value;

    return SeparatedColumn(
      separatorBuilder: (context, _) => const SizedBox(height: 6),
      children: ref.watch(activatedBoostersProvider).when(
            data: (boosters) => boosters
                .where((b) => b.endsAt.isAfter(DateTime.now()))
                .map((e) {
              final boosterItem = config.items
                  .whereType<ItemBooster>()
                  .firstWhere((b) => b.name == e.type);
              final untilEnd = e.endsAt.difference(DateTime.now());
              final untilEndDays = untilEnd.inDays.toString();
              final untilEndHours =
                  (untilEnd.inHours % 24).toString().padLeft(2, '0');
              final untilEndMinutes =
                  (untilEnd.inMinutes % 60).toString().padLeft(2, '0');
              final untilEndSeconds =
                  (untilEnd.inSeconds % 60).toString().padLeft(2, '0');
              final untilEndString = untilEnd.inDays > 0
                  ? '$untilEndDays.$untilEndHours:$untilEndMinutes:$untilEndSeconds'
                  : untilEnd.inHours > 0
                      ? '$untilEndHours:$untilEndMinutes:$untilEndSeconds'
                      : untilEnd.inMinutes > 0
                          ? '$untilEndMinutes:$untilEndSeconds'
                          : untilEndSeconds;

              return GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => HelpDialog(
                    text: boosterItem.description.replaceAll(
                      '{duration}',
                      '${config.boosterDuration} hour',
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    EmojiImage(
                      emoji: boosterItem.emoji,
                      size: 45,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      untilEndString,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            error: (_, __) => [],
            loading: () => [const CircularProgressIndicator()],
          ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/satellite/satellite_bloc.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class SatelliteMenu extends HookConsumerWidget {
  final SatelliteBuilding building;

  const SatelliteMenu(this.building, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocConsumer<SatelliteBloc, SatelliteState>(
      listener: (context, satelliteState) {
        switch (satelliteState) {
          case SatelliteStateShowLines():
            Navigator.of(context).pop();
          default:
            break;
        }
      },
      builder: (context, satelliteState) {
        final config = ref.watch(configProvider).value!;

        return SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmojiImage(
                      emoji: [
                        '🗼',
                        '🛰️',
                        '📡',
                      ][building.level - 1],
                      size: 64,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        children: [
                          AppText(
                            'Level ${building.level}',
                            style: const TextStyle(
                              fontFamily: 'Sansation',
                              fontSize: 28,
                            ),
                          ),
                          AppText(
                            'Collects business income within ${config.satelliteRadius[building.level - 1]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                switch (satelliteState) {
                  SatelliteStateInitial() => ElevatedButton(
                      onPressed: () {
                        context.read<SatelliteBloc>().add(
                              SatelliteEvent.collectedMoney(building.id),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(37),
                        ),
                      ),
                      child: const AppText(
                        'Collect income',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  SatelliteStateLoading() => const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  SatelliteStateShowLines() => ElevatedButton(
                      onPressed: () {
                        context.read<SatelliteBloc>().add(
                              SatelliteEvent.collectedMoney(building.id),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(37),
                        ),
                      ),
                      child: const AppText(
                        'Collect income',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                },
                const Spacer(),
                const AppText(
                  'weekly commission 0%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

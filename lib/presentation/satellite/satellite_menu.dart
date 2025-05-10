import 'package:auto_route/auto_route.dart';
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
            context.router.pop();
          default:
            break;
        }
      },
      builder: (context, satelliteState) {
        final config = ref.watch(configProvider).value!;

        return Center(
          child: Container(
            width: 334,
            height: 277,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
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
                      size: 120,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Level ${building.level}',
                            style: const TextStyle(
                              fontFamily: 'Sansation',
                              fontSize: 48,
                            ),
                          ),
                          Text(
                            'in radius of ${config.satelliteRadius[building.level - 1]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
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
                      child: const Text(
                        'collect',
                        style: TextStyle(
                          fontSize: 24,
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
                      child: const Text(
                        'collect',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                },
                const Spacer(),
                const Text(
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

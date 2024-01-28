import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/doggy_express/doggy_express_step.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';

@RoutePage()
class TruckTypeHelpPage extends HookConsumerWidget {
  const TruckTypeHelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    final cybertruckPrice = (config.trucksCost[1] * 1000).floor().toCurrency();
    final doggyPrice = (config.trucksCost[0] * 1000).floor().toCurrency();
    final planePrice = (config.trucksCost[2] * 1000).floor().toCurrency();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BrowserBar(
        icon: Icons.arrow_back,
        link: 'httgs://doggie-express.com/trucks',
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 89,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Doggie',
                  style: TextStyle(
                    fontFamily: 'Piazzolla',
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333363),
                  ),
                ),
                SizedBox(width: 10),
                EmojiImage(
                  emoji: '🦮',
                  size: 73,
                ),
                SizedBox(width: 10),
                Text(
                  'Express',
                  style: TextStyle(
                    fontFamily: 'Piazzolla',
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333363),
                  ),
                ),
              ],
            ),
          ),
          DoggyExpressStep(
            text: 'Cybertruck 🚚',
            titleSize: 36,
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              top: 20,
              bottom: 37,
            ),
            child: Column(
              children: [
                Text(
                  'Сost of 1 km: $cybertruckPrice 💵',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 33),
                const Text(
                  'Cybertrucks drive at real speed and take into account traffic congestion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          DoggyExpressStep(
            text: 'Doggie 🦮',
            titleSize: 36,
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              top: 20,
              bottom: 37,
            ),
            child: Column(
              children: [
                Text(
                  'Сost of 1 km: $doggyPrice 💵',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 33),
                const Text(
                  'The doggies speed is 75% of the cars speed and they doesn’t take into account traffic',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          DoggyExpressStep(
            text: 'Plane 🛩️',
            titleSize: 36,
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              top: 20,
              bottom: 37,
            ),
            child: Column(
              children: [
                Text(
                  'Сost of 1 km: $planePrice 💵',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 33),
                const Text(
                  'Planes fly in a straight line at extremely high speed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

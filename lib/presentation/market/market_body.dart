import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/market/market_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/market/market_loading.dart';
import 'package:package_flutter/presentation/market/market_resource.dart';

class MarketBody extends HookConsumerWidget {
  const MarketBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocConsumer<MarketBloc, MarketState>(
      listener: (context, state) => state.map(
        initial: (_) {
          return null;
        },
        loadInProgress: (_) {
          return null;
        },
        loadFailure: (s) => context.read<NotificationsBloc>().add(
              NotificationsEvent.warningAdded(s.failure.toString()),
            ),
        loadSuccess: (_) {
          return null;
        },
      ),
      builder: (context, state) {
        return state.map(
          initial: (_) => const MarketLoading(),
          loadInProgress: (_) => const MarketLoading(),
          loadFailure: (_) => const MarketLoading(),
          loadSuccess: (s) {
            final config = ref.watch(configProvider).value!;

            final color = config.items
                .whereType<ItemResource>()
                .firstWhere(
                  (i) => i.group == s.market.level && i.level == 8,
                )
                .color;
            final branchName = [
              'Auto',
              'Music',
              'Tech',
              'Boat',
              'Bread',
            ][s.market.level - 1];
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const EmojiImage(
                          emoji: '🏬',
                          size: 120,
                        ),
                        Container(
                          width: 120,
                          height: 11,
                          color: Color(
                            0xFF000000 + int.parse(color, radix: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 22),
                    Text(
                      '$branchName\nBranch',
                      style: TextStyle(
                        fontSize: 48,
                        fontFamily: 'Sansation',
                        color: Color(
                          0xFF000000 + int.parse(color, radix: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          MarketResource(resourceLevel: 1),
                          SizedBox(height: 10),
                          MarketResource(resourceLevel: 2),
                          SizedBox(height: 10),
                          MarketResource(resourceLevel: 3),
                          SizedBox(height: 10),
                          MarketResource(resourceLevel: 4),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        children: [
                          MarketResource(resourceLevel: 5),
                          SizedBox(height: 10),
                          MarketResource(resourceLevel: 6),
                          SizedBox(height: 10),
                          MarketResource(resourceLevel: 7),
                          SizedBox(height: 10),
                          MarketResource(resourceLevel: 8),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'weekly commission ${(s.market.commission! * 100).floor()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

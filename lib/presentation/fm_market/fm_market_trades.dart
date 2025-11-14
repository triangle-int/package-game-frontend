import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/fm_market/fm_search_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/fm_market/trade_item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';

class FMMarketTrades extends StatefulHookConsumerWidget {
  const FMMarketTrades({
    super.key,
  });

  @override
  ConsumerState<FMMarketTrades> createState() => _FMMarketTradesState();
}

class _FMMarketTradesState extends ConsumerState<FMMarketTrades> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.extentAfter < 100) {
          context.read<FmSearchBloc>().add(const FmSearchEvent.loadMore());
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojiBloc, EmojiState>(
      builder: (context, emojiState) {
        final config = ref.watch(configProvider).value!;
        final items =
            List<ItemResource>.from(config.items.whereType<ItemResource>());
        items.sort((a, b) {
          final cmp = a.level.compareTo(b.level);
          if (cmp != 0) return cmp;
          return a.group.compareTo(b.group);
        });

        return BlocBuilder<FmSearchBloc, FmSearchState>(
          builder: (context, fmSearchState) {
            // if (fmSearchState.isSearching) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }

            if (fmSearchState.isSearchOpen) {
              return ListView.separated(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                itemCount: config.items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 25),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final hasInFilter = fmSearchState.filters.contains(item.name);

                  return FilterTradeItem(hasInFilter: hasInFilter, item: item);
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FmSearchBloc>().add(
                      const FmSearchEvent.search(),
                    );
                await Future.doWhile(
                  () =>
                      context.mounted &&
                      context.read<FmSearchBloc>().state.isSearching,
                );
              },
              backgroundColor: Colors.white,
              child: fmSearchState.searchResults.isNotEmpty
                  ? GridView.count(
                      controller: _controller,
                      crossAxisCount: 2,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 11,
                      childAspectRatio: 193 / 185,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 63,
                      ),
                      children: fmSearchState.searchResults.map((e) {
                        return Trade(
                          config: config,
                          trade: e,
                        );
                      }).toList(),
                    )
                  : const Center(
                      child: Text(
                        'No trades 🛒',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

class Trade extends HookConsumerWidget {
  const Trade({super.key, required this.config, required this.trade});

  final Config config;
  final TradeItem trade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = config.items
        .whereType<ItemResource>()
        .firstWhere((element) => element.name == trade.name)
        .color;
    final emoji = config.items
        .whereType<ItemResource>()
        .firstWhere((element) => element.name == trade.name)
        .emoji;
    final count = trade.count.toCurrency();
    final price = trade.pricePerUnit.toCurrency();
    final ownerNickname = trade.owner.nickname;
    final ownerAvatar = trade.owner.avatar;

    final user = ref.watch(userProvider).value!;

    return ElevatedButton(
      onPressed: () {
        if (trade.ownerId == user.id) return;
        context.router.push(BuyRoute(tradeItem: trade));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        padding: const EdgeInsets.all(7),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(
                    0xFF000000 + int.parse(color, radix: 16),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Hero(
                    tag: 'product_${trade.id}',
                    child: EmojiImage(emoji: emoji),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$count 📦',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              height: 1,
            ),
          ),
          Text(
            '$price 💵',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              height: 1,
            ),
          ),
          Text(
            '$ownerAvatar $ownerNickname',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterTradeItem extends StatelessWidget {
  const FilterTradeItem({
    super.key,
    required this.hasInFilter,
    required this.item,
  });

  final bool hasInFilter;
  final ItemResource item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 60),
      child: ElevatedButton(
        onPressed: hasInFilter
            ? () {
                AudioPlayer().play(AssetSource('sounds/mouse_click.wav'));
                context.read<FmSearchBloc>().add(
                      FmSearchEvent.removeFilter(
                        item.name,
                      ),
                    );
              }
            : () {
                AudioPlayer().play(AssetSource('sounds/mouse_click.wav'));
                context.read<FmSearchBloc>().add(
                      FmSearchEvent.addFilter(
                        item.name,
                      ),
                    );
              },
        style: ElevatedButton.styleFrom(
          elevation: hasInFilter ? 0 : 2,
          backgroundColor: hasInFilter ? const Color(0xFFCACACA) : Colors.white,
          fixedSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 30),
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 27),
            ),
            const SizedBox(width: 5),
            Text(
              item.name
                  .split('_')
                  .map(
                    (e) => e[0].toUpperCase() + e.substring(1),
                  )
                  .join(' '),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/currency_change.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';
import 'package:package_flutter/l10n/app_text.dart';

final soloMarketCatalogProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ref.watch(dioProvider).get('/solo-market/catalog');
  return (response.data as List<dynamic>)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
});

class SoloMarketPage extends ConsumerWidget {
  const SoloMarketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(soloMarketCatalogProvider);
    final config = ref.watch(configProvider).valueOrNull;
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: const BrowserBar(
          icon: Icons.arrow_back, link: 'httgs://survival-market.net/'),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const Center(child: AppText('Could not load market')),
        data: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppText('Survival Market',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const AppText(
              'Emergency supply. Buying is expensive, selling is deliberately cheap. '
              'Selling takes resources from your warehouses.',
            ),
            const SizedBox(height: 16),
            for (final item in items)
              _SoloMarketItem(
                  item: item,
                  emoji: _emoji(config, item['name'] as String),
                  dio: ref.read(dioProvider)),
          ],
        ),
      ),
    );
  }

  String _emoji(Config? config, String name) {
    if (config == null) return '📦';
    return config.getItemByName(name).emoji;
  }
}

class _SoloMarketItem extends StatefulWidget {
  const _SoloMarketItem(
      {required this.item, required this.emoji, required this.dio});
  final Map<String, dynamic> item;
  final String emoji;
  final Dio dio;

  @override
  State<_SoloMarketItem> createState() => _SoloMarketItemState();
}

class _SoloMarketItemState extends State<_SoloMarketItem> {
  final count = TextEditingController(text: '1');
  bool busy = false;

  Future<void> _trade(String action) async {
    final amount = int.tryParse(count.text) ?? 0;
    if (amount <= 0) return;
    setState(() => busy = true);
    try {
      await widget.dio.post('/solo-market/$action', data: {
        'resource': widget.item['name'],
        'count': amount,
      });
      if (!mounted) return;
      final unitPrice = BigInt.from(
          widget.item[action == 'buy' ? 'buyPrice' : 'sellPrice'] as int);
      showCurrencyChange(
          context,
          action == 'buy'
              ? -unitPrice * BigInt.from(amount)
              : unitPrice * BigInt.from(amount));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: AppText(action == 'buy' ? 'Purchased' : 'Sold')));
      }
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(_tradeError(error)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _tradeError(DioException error) {
    final data = error.response?.data;
    final message = data is Map ? data['message'] : null;
    return switch (message) {
      'notEnoughMoney' => 'Not enough money',
      'notEnoughResources' => 'Not enough resources',
      'storageNotFound' => 'Warehouse not found',
      'resourceNotFound' => 'Resource not found',
      _ => 'Trade failed',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            EmojiImage(emoji: widget.emoji, size: 38),
            const SizedBox(width: 10),
            Expanded(child: AppText(widget.item['name'] as String)),
            SizedBox(
                width: 48,
                child: TextField(
                    controller: count, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Column(
              children: [
                AppText('Buy ${widget.item['buyPrice']} 💵'),
                AppText('Sell ${widget.item['sellPrice']} 💵'),
              ],
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                FilledButton.tonal(
                  onPressed: busy ? null : () => _trade('buy'),
                  child: const AppText('Buy'),
                ),
                FilledButton.tonal(
                  onPressed: busy ? null : () => _trade('sell'),
                  child: const AppText('Sell'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    count.dispose();
    super.dispose();
  }
}

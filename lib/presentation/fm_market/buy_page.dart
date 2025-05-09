import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/fm_market/buy/buy_bloc.dart';
import 'package:package_flutter/bloc/fm_market/fm_search_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/domain/fm_market/buy_failure.dart';
import 'package:package_flutter/domain/fm_market/fm_market_repository.dart';
import 'package:package_flutter/domain/fm_market/trade_item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/fm_market/close_bar.dart';
import 'package:package_flutter/presentation/fm_market/fm_market_logo.dart';

import 'package:package_flutter/presentation/noodle/browser_bar.dart';

@RoutePage()
class BuyPage extends HookConsumerWidget {
  final TradeItem tradeItem;

  const BuyPage({super.key, required this.tradeItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    final scrollController = useScrollController();
    final isEditing = useState(false);
    useEffect(
      () {
        textEditingController.text = tradeItem.count.toString();
        return null;
      },
      [],
    );
    final config = ref.watch(configProvider).value!;

    return BlocProvider(
      create: (context) => BuyBloc(ref.watch(fmMarketRepositoryProvider))
        ..add(BuyEvent.amountUpdated(tradeItem.count)),
      child: BlocConsumer<BuyBloc, BuyState>(
        listener: (context, buyState) {
          if (buyState.failureOrNull != null) {
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.warningAdded(
                    switch (buyState.failureOrNull!) {
                      BuyFailureInvalidAmount() => 'Amount is invalid',
                      BuyFailureServerFailure(:final failure) =>
                        failure.getMessage(),
                    },
                  ),
                );
          }
          if (buyState.success) {
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.successAdded(
                    'You bought ${buyState.amount.toCurrency()} ${config.getItemByName(tradeItem.name).emoji}, now they are in the warehouse of the store.',
                  ),
                );
            context.router.pop();
            context.read<FmSearchBloc>().add(const FmSearchEvent.search());
          }
        },
        builder: (context, buyState) {
          return Scaffold(
            backgroundColor: const Color(0xFFEEEEEE),
            appBar: const BrowserBar(
              icon: Icons.arrow_back,
              link: 'httgs://razvoda.net/buy',
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 25),
              physics: const ClampingScrollPhysics(),
              controller: scrollController,
              child: Column(
                children: [
                  const Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 89),
                        child: CloseBar(showMoney: true),
                      ),
                      FMMarketLogo(),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(49),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Hero(
                          tag: 'product_${tradeItem.id}',
                          child: EmojiImage(
                            emoji: config.getItemByName(tradeItem.name).emoji,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${tradeItem.count} 📦',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tradeItem.owner.nickname,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 38),
                  Container(
                    width: 284,
                    height: 64,
                    padding: const EdgeInsets.only(right: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(-2, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            onTap: () {
                              isEditing.value = true;
                            },
                            onChanged: (text) {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn,
                              );
                              if (text.isNotEmpty &&
                                  BigInt.parse(text) > tradeItem.count) {
                                textEditingController.text =
                                    tradeItem.count.toString();
                              }
                              context.read<BuyBloc>().add(
                                    BuyEvent.amountUpdated(
                                      BigInt.tryParse(
                                            textEditingController.text,
                                          ) ??
                                          BigInt.from(0),
                                    ),
                                  );
                            },
                            onEditingComplete: () {
                              FocusManager.instance.primaryFocus!.unfocus();
                              isEditing.value = false;
                            },
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'amount',
                              hintStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF656565),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isEditing.value) {
                              FocusManager.instance.primaryFocus!.unfocus();
                              isEditing.value = false;
                            } else {
                              context.read<BuyBloc>().add(
                                    BuyEvent.amountUpdated(tradeItem.count),
                                  );
                              textEditingController.text =
                                  tradeItem.count.toString();
                            }
                          },
                          icon: isEditing.value
                              ? const Icon(Icons.done_rounded)
                              : const Icon(Icons.add_rounded),
                          color: Colors.black,
                          padding: EdgeInsets.zero,
                          iconSize: 62,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 42),
                  Text(
                    '${tradeItem.pricePerUnit.toCurrency()} 💵 per each',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 17),
                  TextOrBuyButton(
                    tradeItem: tradeItem,
                    isEditing: isEditing.value,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TextOrBuyButton extends StatelessWidget {
  const TextOrBuyButton({
    super.key,
    required this.tradeItem,
    required this.isEditing,
  });

  final TradeItem tradeItem;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyBloc, BuyState>(
      builder: (context, buyState) {
        final price = (BigInt.from(tradeItem.pricePerUnit) * buyState.amount)
            .toCurrency();

        if (buyState.isLoading) {
          return const SizedBox(
            height: 51,
            width: 51,
            child: CircularProgressIndicator(),
          );
        }

        if (isEditing) {
          return Text(
            'total $price 💵',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          );
        }

        return ElevatedButton(
          onPressed: () => context
              .read<BuyBloc>()
              .add(BuyEvent.bought(tradeId: tradeItem.id)),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(130),
            ),
            elevation: 4,
            fixedSize: const Size(327, 51),
          ),
          child: Text(
            'buy for $price 💵',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

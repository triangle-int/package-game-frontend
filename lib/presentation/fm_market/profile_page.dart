import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/fm_market/profile/fm_profile_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/fm_market/fm_market_repository.dart';
import 'package:package_flutter/domain/fm_market/my_trade.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/fm_market/close_bar.dart';
import 'package:package_flutter/presentation/fm_market/fm_market_logo.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';
import 'package:separated_column/separated_column.dart';

@RoutePage()
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) => FmProfileBloc(ref.watch(fmMarketRepositoryProvider))
        ..add(const FmProfileEvent.fetchTradesRequested()),
      child: BlocConsumer<FmProfileBloc, FmProfileState>(
        listener: (context, profileState) {
          if (profileState.failureOrNull != null) {
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.warningAdded(
                    profileState.failureOrNull!.getMessage(),
                  ),
                );
          }
        },
        builder: (context, profileState) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              backgroundColor: const Color(0xFFEEEEEE),
              appBar: const BrowserBar(
                icon: Icons.arrow_back,
                link: 'httgs://razvoda.net/profile',
              ),
              body: Column(
                children: [
                  const Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 89),
                        child: CloseBar(showMoney: false),
                      ),
                      FMMarketLogo(),
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<FmProfileBloc>()
                            .add(const FmProfileEvent.fetchTradesRequested());
                      },
                      backgroundColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      child: ListView(
                        padding: const EdgeInsets.only(
                          right: 28,
                          left: 28,
                          bottom: 40,
                        ),
                        children: [
                          const SizedBox(height: 17),
                          const Center(
                            child: ProfileAvatar(),
                          ),
                          const SizedBox(height: 13),
                          const ProfileNickname(),
                          const SizedBox(height: 40),
                          if (profileState.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            SeparatedColumn(
                              children: profileState.trades
                                  .map((t) => ProfileProduct(trade: t))
                                  .toList(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 40),
                            ),
                        ],
                      ),
                    ),
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

class ProfileProduct extends HookConsumerWidget {
  const ProfileProduct({
    super.key,
    required this.trade,
  });

  final MyTrade trade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final averagePrice = trade.average.pricePerUnit?.ceil().toCurrency() ?? '0';
    final minPrice = trade.min.pricePerUnit?.ceil().toCurrency() ?? '0';
    final amount = trade.count.toCurrency();

    useEffect(
      () {
        controller.text = trade.pricePerUnit.toString();
        return null;
      },
      [],
    );

    final config = ref.watch(configProvider).value!;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
          height: 124,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'average',
                    style: TextStyle(
                      color: Color(0xFF656565),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'minimal',
                    style: TextStyle(
                      color: Color(0xFF656565),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'yours',
                    style: TextStyle(
                      color: Color(0xFF656565),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$averagePrice 💵',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$minPrice 💵',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 29,
                    width: 101,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            width: 0,
                            color: Color(0xFFEEEEEE),
                          ),
                        ),
                        fillColor: Color(0xFFEEEEEE),
                        filled: true,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        hintText: 'price',
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (text) {
                        if (text.isEmpty) return;
                        context.read<FmProfileBloc>().add(
                              FmProfileEvent.priceChanged(
                                tradeId: trade.id,
                                newPrice: int.tryParse(text) ?? 0,
                              ),
                            );
                        context
                            .read<TutorialBloc>()
                            .add(const TutorialEvent.priceSet());
                      },
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              EmojiImage(
                emoji: config.getItemByName(trade.name).emoji,
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            height: 35,
            width: double.infinity,
            child: Center(
              child: Text(
                'you selling $amount',
                style: const TextStyle(
                  color: Color(0xFF656565),
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileNickname extends HookConsumerWidget {
  const ProfileNickname({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            user.nickname,
            style: const TextStyle(
              color: Color(0xFF656565),
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends HookConsumerWidget {
  const ProfileAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;

    return BlocBuilder<EmojiBloc, EmojiState>(
      builder: (context, emojiState) {
        return Container(
          width: 139,
          height: 139,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFFCACACA),
              width: 6,
            ),
          ),
          child: EmojiImage(emoji: user.avatar),
        );
      },
    );
  }
}

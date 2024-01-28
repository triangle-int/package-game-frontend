import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/state_national_marketplace/snm_currency.dart';

class SNMUserStatus extends HookConsumerWidget {
  const SNMUserStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;

    final money = user.money.toCurrency();
    final gems = user.gems.toCurrency();

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SNMCurrency(currency: '$money 💵'),
              const Spacer(),
            ],
          ),
        ),
        EmojiImage(emoji: user.avatar, size: 40),
        Expanded(
          child: Row(
            children: [
              const Spacer(),
              SNMCurrency(currency: '$gems 💎'),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/doggie_express/amount_and_product/amount_and_product_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';

class AmountAndProduct extends HookConsumerWidget {
  const AmountAndProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
      builder: (context, doggieExpressState) {
        final isActiveProduct = doggieExpressState.pointA != null &&
            doggieExpressState.pointB != null;
        final isActiveAmount = doggieExpressState.resource != '';

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(160, 45),
                    fixedSize: const Size(160, 45),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF8D8D8D),
                    padding: const EdgeInsets.all(4),
                    side: BorderSide(
                      color: isActiveProduct
                          ? Colors.white
                          : const Color(0xFF8D8D8D),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: isActiveProduct
                      ? () => context.read<AmountAndProductBloc>().add(
                            AmountAndProductEvent.productOpened(
                              doggieExpressState.pointA!,
                              doggieExpressState.pointB!,
                              config,
                            ),
                          )
                      : null,
                  child: doggieExpressState.resource == ''
                      ? const Text(
                          'PRODUCT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : EmojiImage(
                          emoji: config
                              .getItemByName(doggieExpressState.resource)
                              .emoji,),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(160, 45),
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: isActiveAmount
                          ? Colors.white
                          : const Color(0xFF8D8D8D),
                      width: 2,
                    ),
                    disabledForegroundColor: const Color(0xFF8D8D8D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: isActiveAmount
                      ? () => context.read<AmountAndProductBloc>().add(
                            AmountAndProductEvent.amountOpened(
                              doggieExpressState.pointA!,
                              doggieExpressState.resource,
                            ),
                          )
                      : null,
                  child: Text(
                    doggieExpressState.amount == BigInt.from(0)
                        ? 'AMOUNT'
                        : doggieExpressState.amount.toCurrency(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/doggie_express/amount_and_product/amount_and_product_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class ProductConfirm extends HookConsumerWidget {
  const ProductConfirm({
    super.key,
    required this.items,
  });

  final List<Item> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
      builder: (context, doggieExpressState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 45,
                  width: 160,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: doggieExpressState.resource == ''
                        ? null
                        : EmojiImage(
                            emoji: config
                                .getItemByName(doggieExpressState.resource)
                                .emoji,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(160, 45),
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    context.read<AmountAndProductBloc>().add(
                          const AmountAndProductEvent.initialOpened(),
                        );
                  },
                  child: const Text(
                    'CONFIRM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 17, right: 22, left: 22),
              itemBuilder: (context, index) => OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(45, 45),
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(7),
                ),
                onPressed: () => context.read<DoggieExpressBloc>().add(
                    DoggieExpressEvent.resourceSelected(items[index].name),),
                child: EmojiImage(emoji: items[index].emoji),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:package_flutter/bloc/doggie_express/amount_and_product/amount_and_product_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';

class AmountConfirm extends HookWidget {
  const AmountConfirm({
    super.key,
    required this.maxAmount,
  });

  final BigInt maxAmount;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    useEffect(
      () {
        if (context.read<DoggieExpressBloc>().state.amount != BigInt.from(0)) {
          controller.text =
              context.read<DoggieExpressBloc>().state.amount.toString();
        }
        return null;
      },
      [],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
          onPressed: () => context
              .read<AmountAndProductBloc>()
              .add(const AmountAndProductEvent.initialOpened()),
          child: const Text(
            'CONFIRM',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 160,
          height: 45,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: controller,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8D8D8D),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              focusColor: Colors.white,
              hintText: maxAmount.toCurrency(),
            ),
            onChanged: (text) {
              BigInt amount = BigInt.tryParse(text) ?? BigInt.from(0);
              if (amount > maxAmount) {
                amount = maxAmount;
                controller.text = amount.toString();
              }
              context
                  .read<DoggieExpressBloc>()
                  .add(DoggieExpressEvent.amountEntered(amount));
            },
          ),
        ),
      ],
    );
  }
}

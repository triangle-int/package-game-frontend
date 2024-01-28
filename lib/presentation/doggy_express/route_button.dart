import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';

class RouteButton extends HookConsumerWidget {
  const RouteButton({
    super.key,
    required this.isStart,
  });

  final bool isStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
      builder: (context, state) {
        String text;
        if (isStart) {
          text = state.pointA == null ? '1' : state.pointA!.getEmoji(config);
        } else {
          text = state.pointB == null ? '2' : state.pointB!.getEmoji(config);
        }

        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
            fixedSize: const Size.square(45),
            minimumSize: const Size.square(45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () => isStart
              ? context
                  .read<DoggieExpressBloc>()
                  .add(const DoggieExpressEvent.pointADeselected())
              : context
                  .read<DoggieExpressBloc>()
                  .add(const DoggieExpressEvent.pointBDeselected()),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

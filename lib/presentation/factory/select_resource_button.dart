import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/factory/resource/factory_resource_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class SelectResourceButton extends HookConsumerWidget {
  final String resourceName;

  const SelectResourceButton({
    super.key,
    required this.resourceName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<FactoryResourceBloc, FactoryResourceState>(
      builder: (context, factoryResourceState) {
        final isSelected = factoryResourceState.resource == resourceName;
        final emoji =
            config.items.firstWhere((i) => i.name == resourceName).emoji;
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => context.read<FactoryResourceBloc>().add(
                        FactoryResourceEvent.resourceSelected(resourceName),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: EmojiImage(emoji: emoji),
                  ),
                ),
              ),
              if (isSelected) ...[
                Positioned(
                  right: 10,
                  bottom: 10,
                  width: 19,
                  height: 19,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}

import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/factory/resource/factory_resource_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class SelectResourceButton extends HookConsumerWidget {
  final String resourceName;

  const SelectResourceButton({super.key, required this.resourceName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;
    return BlocBuilder<FactoryResourceBloc, FactoryResourceState>(
      builder: (context, state) {
        final isSelected = state.resource == resourceName;
        final emoji =
            config.items.firstWhere((i) => i.name == resourceName).emoji;
        final label = resourceName.replaceAll('_', ' ');
        return SizedBox(
          width: 82,
          child: Material(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: state.isLoading
                  ? null
                  : () => context.read<FactoryResourceBloc>().add(
                        FactoryResourceEvent.resourceSelected(resourceName),
                      ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  children: [
                    EmojiImage(emoji: emoji, size: 36),
                    const SizedBox(height: 4),
                    AppText(label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : null)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

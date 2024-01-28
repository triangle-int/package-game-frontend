import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/user/create_user/create_user_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class AvatarField extends HookConsumerWidget {
  const AvatarField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<EmojiBloc, EmojiState>(
      builder: (context, emojiState) {
        final avatars = ref.watch(configProvider).value!.avatars;

        return BlocBuilder<CreateUserBloc, CreateUserState>(
          builder: (context, createUserState) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 22,
                crossAxisSpacing: 30,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 18,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                final itemAvatar = avatars[index];
                final isHighlighted = createUserState.avatar == itemAvatar;
                return ElevatedButton(
                  onPressed: () => context
                      .read<CreateUserBloc>()
                      .add(CreateUserEvent.avatarChanged(itemAvatar)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighlighted
                        ? const Color(0xFF4B4B4B)
                        : const Color(0xFF1D1D1D),
                    shape: const CircleBorder(),
                    elevation: 5,
                    shadowColor: Colors.black,
                  ),
                  child: EmojiImage(emoji: itemAvatar),
                );
              },
            );
          },
        );
      },
    );
  }
}

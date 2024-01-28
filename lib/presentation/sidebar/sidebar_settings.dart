import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/root/map_dark_mode.dart';
import 'package:package_flutter/presentation/core/root/sfx_volume.dart';
import 'package:package_flutter/presentation/sidebar/sidebar_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wiredash/wiredash.dart';

class SidebarSettings extends HookConsumerWidget {
  const SidebarSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const EmojiImage(
                  emoji: '🔊',
                  size: 24,
                ),
                Slider(
                  onChanged: (value) {
                    ref.read(sfxVolumeProvider.notifier).setVolume(value);
                  },
                  value: ref.watch(sfxVolumeProvider),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const EmojiImage(
                  emoji: '⬜️',
                  size: 24,
                ),
                Switch(
                  value: ref.watch(mapDarkModeProvider),
                  onChanged: (value) {
                    ref.watch(mapDarkModeProvider.notifier).setDarkMode(value);
                  },
                ),
                const EmojiImage(
                  emoji: '⬛️',
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SidebarItem(
            text: 'Feedback',
            emoji: '📣',
            onTap: () {
              Wiredash.of(context).show();
            },
          ),
          const SizedBox(height: 16),
          SidebarItem(
            text: 'Support',
            emoji: '☎',
            onTap: () async {
              final Uri url =
                  Uri.parse('https://t.me/package_game_support_bot');
              await launchUrl(url);
            },
          ),
        ],
      ),
    );
  }
}

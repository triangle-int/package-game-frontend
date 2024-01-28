import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/sidebar/music_volume_provider.dart';

class Music extends ConsumerStatefulWidget {
  final Widget child;

  const Music({super.key, required this.child});

  @override
  ConsumerState<Music> createState() => _MusicState();
}

class _MusicState extends ConsumerState<Music> {
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music_player');

  @override
  void initState() {
    super.initState();

    // initMusicPlayer();
  }

  Future<void> initMusicPlayer() async {
    await _musicPlayer.release();
    await _musicPlayer.play(AssetSource('sounds/soundtrack_2.wav'));
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(musicVolumeProvider, (previous, next) {
      _musicPlayer.setVolume(next);
    });

    return widget.child;
  }

  @override
  void dispose() {
    _musicPlayer.release();

    super.dispose();
  }
}

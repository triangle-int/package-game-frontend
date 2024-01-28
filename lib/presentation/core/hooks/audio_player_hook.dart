import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AudioPlayer useAudioPlayer() {
  return use(const _AudioPlayerHook());
}

class _AudioPlayerHook extends Hook<AudioPlayer> {
  const _AudioPlayerHook();

  @override
  _AudioPlayerHookState createState() => _AudioPlayerHookState();
}

class _AudioPlayerHookState extends HookState<AudioPlayer, _AudioPlayerHook> {
  late final AudioPlayer audioPlayer;

  @override
  void initHook() {
    super.initHook();
    audioPlayer = AudioPlayer();
  }

  @override
  AudioPlayer build(BuildContext context) {
    return audioPlayer;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

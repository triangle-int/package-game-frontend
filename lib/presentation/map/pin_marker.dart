import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/pin_marker/pin_marker_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class PinMarker extends StatefulWidget {
  const PinMarker({super.key});

  @override
  State<PinMarker> createState() => _PinMarkerState();
}

class _PinMarkerState extends State<PinMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      // This takes in the TickerProvider, which is this _AnimationPageState object
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );

    _animation = Tween<double>(begin: -1, end: 1).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PinMarkerBloc, PinMarkerState>(
      listener: (context, state) {
        if (state.isShown) _animationController.forward(from: 0);
      },
      child: Align(
        alignment: Alignment(0, _animation.value),
        child: const EmojiImage(
          size: 30,
          emoji: '📍',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

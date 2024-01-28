import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/map/build_mode/build_mode_bloc.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class DestroyModeMenu extends StatefulWidget {
  const DestroyModeMenu({super.key});

  @override
  State<DestroyModeMenu> createState() => _DestroyModeMenuState();
}

class _DestroyModeMenuState extends State<DestroyModeMenu> {
  PersistentBottomSheetController? destroyModeController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuildModeBloc, BuildModeState>(
      listener: (context, state) {
        state.map(
          buildMode: (_) {
            destroyModeController?.close();
            destroyModeController = null;
          },
          destroyMode: (_) {
            destroyModeController = showBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(37),
                ),
              ),
              builder: (context) => SizedBox(
                height: 100,
                child: Center(
                  child: IconButton(
                    onPressed: () => context
                        .read<BuildModeBloc>()
                        .add(const BuildModeEvent.exitedDestroyMode()),
                    icon: const EmojiImage(emoji: '❌'),
                  ),
                ),
              ),
            );
            destroyModeController!.closed.then((_) {
              context
                  .read<BuildModeBloc>()
                  .add(const BuildModeEvent.exitedDestroyMode());
            });
          },
        );
      },
      child: Container(),
    );
  }
}

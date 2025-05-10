import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/factory/upgrade/factory_upgrade_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building.dart';

class FactoryMarker extends StatefulHookConsumerWidget {
  const FactoryMarker(
    this.factoryBuilding, {
    super.key,
  });

  final FactoryBuilding factoryBuilding;

  @override
  ConsumerState<FactoryMarker> createState() => _FactoryMarkerState();
}

class _FactoryMarkerState extends ConsumerState<FactoryMarker> {
  bool isUpgrading = false;
  // StateMachineController? controller;

  // SMITrigger? _upgradeTrigger;

  // Future<void> _onRiveInit(Artboard artboard) async {
  //   Logger().d('Rive marker Factory initializing...');
  //   // Get State Machine Controller for the state machine called "bumpy"
  //   controller = StateMachineController.fromArtboard(
  //     artboard,
  //     'State Machine',
  //     onStateChange: _onStateChange,
  //   );
  //   artboard.addController(controller!);
  //   // Get a reference to the "bump" state machine input
  //   _upgradeTrigger = controller!.findInput<bool>('Upgrade') as SMITrigger?;
  //   Logger().d('Updated trigger');
  //   await Future.delayed(const Duration(milliseconds: 50));
  //   controller!.isActive = widget.factoryBuilding.enabled;
  // }

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        // controller?.isActive = widget.factoryBuilding.enabled;
        return null;
      },
      [widget.factoryBuilding],
    );
    final user = ref.watch(userProvider).value!;

    return BlocListener<FactoryUpgradeBloc, FactoryUpgradeState>(
      listener: (context, upgradeState) {
        // upgradeState.map(
        //   initial: (_) {},
        //   loadInProgress: (_) {},
        //   loadSuccess: (s) {
        //     if (s.building.id != widget.factoryBuilding.id) {
        //       return;
        //     }
        //     Logger()
        //         .d('Playing upgrade animation, trigger is $_upgradeTrigger');
        //     _upgradeTrigger?.fire();
        //   },
        //   loadFailure: (s) {},
        // );
      },
      child: Builder(
        builder: (context) {
          final iconName = widget.factoryBuilding.ownerId == user.id
              ? 'factory_friend'
              : 'factory_enemy';

          return Image.asset(
            'assets/images/buildings/$iconName.png',
          );
        },
      ),
    );
  }

  // void _onStateChange(
  //   String stateMachineName,
  //   String stateName,
  // ) {
  //   Logger().d('New factory state: $stateName');
  // }
}
